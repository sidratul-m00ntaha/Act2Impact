from django.shortcuts import render
from .models import Task, Profile
from .forms import TaskForm, UserRegistrationForm
from django.shortcuts import get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login
from django.db.models import Q
# Create your views here.
def index (request):
    return render(request, 'index.html')

def task_list(request):
    tasks = Task.objects.all().order_by('-created_at')
    return render(request, 'task_list.html', {'tasks': tasks})

# @login_required
# def task_create(request):
#     if request.method == "POST":
#         form = TaskForm(request.POST, request.FILES)
#         task = form.save(commit=False)
#         task.user = request.user
#         task.save()
#         return redirect('task_list')
#     else:
#         form = TaskForm()
#     return render(request, 'task_form.html', {'form': form})

@login_required
def task_create(request):
    if request.method == "POST":
        form = TaskForm(request.POST, request.FILES)
        if form.is_valid():
            task = form.save(commit=False)
            task.user = request.user
            task.save()

            # Add points to profile after task creation
            profile = request.user.profile
            profile.total_points += task.points

            # Update badge
            if profile.total_points >= 300:
                profile.badge = 'Gold'
            elif profile.total_points >= 150:
                profile.badge = 'Silver'
            else:
                profile.badge = 'Bronze'

            profile.save()

            return redirect('task_list')
    else:
        form = TaskForm()
    return render(request, 'task_form.html', {'form': form})


@login_required
def task_edit(request, task_id):
    task = get_object_or_404(Task, pk=task_id, user = request.user)
    if request.method == "POST":
        form = TaskForm(request.POST, request.FILES, instance=task)
        if form.is_valid():
            task = form.save(commit=False)
            task.user = request.user
            task.save()
            return redirect('task_list')
    else:
        form = TaskForm(instance=task)
    return render(request, 'task_form.html', {'form': form})

@login_required
def task_delete(request, task_id):
    task = get_object_or_404(Task, pk=task_id, user = request.user)
    if request.method == "POST":
        task.delete()
        return redirect('task_list')
    return render(request, 'task_confirm_delete.html', {'task': task})


def register(request):
    if request.method == 'POST':
        form = UserRegistrationForm(request.POST)
        if form.is_valid():
            user = form.save(commit=False)
            user.set_password(form.cleaned_data['password1'])
            user.save()
            login(request, user)
            return redirect('task_list')
    else:
        form = UserRegistrationForm()
        
    return render(request, 'registration/register.html', {'form': form})

def task_search(request):
    query = request.GET.get('q')
    results = []

    if query:
        results = Task.objects.filter(type__icontains=query).order_by('-created_at')

    return render(request, 'task_search_results.html', {'results': results, 'query': query})

@login_required
def complete_task(request, task_id):
    task = get_object_or_404(Task, id=task_id)
    profile = request.user.profile
    profile.total_points += task.points

    # Badge logic
    if profile.total_points >= 300:
        profile.badge = 'Gold'
    elif profile.total_points >= 150:
        profile.badge = 'Silver'
    else:
        profile.badge = 'Bronze'

    profile.save()

    # maybe redirect to a success page
    return redirect('task_list')

@login_required
def dashboard(request):
    profile = Profile.objects.get(user=request.user)

    # Calculate progress
    if profile.total_points < 150:
        progress_percentage = int((profile.total_points / 150) * 100)
    elif profile.total_points < 300:
        progress_percentage = int(((profile.total_points - 150) / 150) * 100)
    else:
        progress_percentage = 100

    return render(request, 'dashboard.html', {
        'profile': profile,
        'progress_percentage': progress_percentage
    })

@login_required
def leaderboard(request):
    profiles = Profile.objects.order_by('-total_points')[:10]
    return render(request, 'leaderboard.html', {'profiles': profiles})

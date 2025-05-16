from django.contrib import admin
from .models import Task, Profile

@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ('user', 'text', 'points', 'type')

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'total_points', 'badge')

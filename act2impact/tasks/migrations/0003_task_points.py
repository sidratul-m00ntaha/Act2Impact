# Generated by Django 5.1.7 on 2025-04-25 16:14

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tasks', '0002_task_type'),
    ]

    operations = [
        migrations.AddField(
            model_name='task',
            name='points',
            field=models.PositiveIntegerField(default=10),
        ),
    ]

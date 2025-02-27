# Generated by Django 5.1.5 on 2025-02-04 18:05

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Song',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=255)),
                ('artist', models.CharField(max_length=255)),
                ('album', models.CharField(blank=True, max_length=255, null=True)),
                ('genre', models.CharField(blank=True, max_length=255, null=True)),
                ('file_path', models.TextField()),
                ('fingerprint', models.BinaryField(blank=True, null=True)),
            ],
        ),
    ]

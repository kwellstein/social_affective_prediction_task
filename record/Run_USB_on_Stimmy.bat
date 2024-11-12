call "C:/Users/All Users/Miniconda3/Scripts/activate.bat" JJ
set /p task=Which python script do you want to run?:
call python -i %task%.py
pause
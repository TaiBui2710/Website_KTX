@echo off
rem Bien dich code Java trong src vao WebContent\WEB-INF\classes (chay lai moi khi sua file .java)
cd /d "%~dp0"
if not exist WebContent\WEB-INF\classes mkdir WebContent\WEB-INF\classes
"C:\Program Files\Java\jdk-21\bin\javac" -encoding UTF-8 -cp "C:\xampp\tomcat\lib\servlet-api.jar" -d WebContent\WEB-INF\classes src\controller\*.java src\model\bean\*.java src\model\bo\*.java src\model\dao\*.java
if errorlevel 1 (echo === BIEN DICH LOI, xem thong bao o tren ===) else (echo === Bien dich xong. Trong VS Code: chuot phai Tomcat 10.x - Publish Server Full ===)
pause
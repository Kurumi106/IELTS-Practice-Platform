\# IELTS Practice Platform



Dự án xây dựng website luyện thi IELTS trực tuyến, hỗ trợ người học thực hành và cải thiện 4 kỹ năng: Listening, Reading, Writing và Speaking.



\## Cấu trúc thư mục



```text

IELTS-Practice-Platform/

├── backend/       # Backend Node.js, Express.js

├── frontend/      # Frontend React, Vite

├── ielts\_platform.sql  # Database MySQL

├── .gitignore

└── README.md

```



\## Công nghệ sử dụng



\- Frontend: ReactJS, Vite, Axios, React Router DOM

\- Backend: Node.js, Express.js

\- Database: MySQL 8.0



\## Cài đặt và chạy dự án



\### 1. Clone repository



```bash

git clone https://github.com/Kurumi106/IELTS-Practice-Platform.git

cd IELTS-Practice-Platform

```



\### 2. Cài đặt Database



\- Mở MySQL Workbench.

\- Chạy file `ielts\_platform.sql` để tạo database.



\### 3. Cấu hình Backend



Tạo file `backend/.env`:



```env

PORT=5000

DB\_HOST=localhost

DB\_PORT=3306

DB\_NAME=ielts\_platform

DB\_USER=root

DB\_PASSWORD=your\_mysql\_password

```



Cài đặt và chạy:



```bash

cd backend

npm install

npm run dev

```



Backend: http://localhost:5000



\### 4. Cài đặt Frontend



Mở terminal mới:



```bash

cd frontend

npm install

npm run dev

```



Frontend: http://localhost:5173



\## Repository



GitHub: https://github.com/Kurumi106/IELTS-Practice-Platform




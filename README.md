# IELTS Practice Platform



# Dự án xây dựng website luyện thi IELTS trực tuyến, hỗ trợ người học thực hành và cải thiện 4 kỹ năng: Listening, Reading, Writing và Speaking.



## Cấu trúc thư mục



```text

IELTS-Practice-Platform/

├── backend/       # Backend Node.js, Express.js

├── frontend/      # Frontend React, Vite

├── ielts_platform.sql  # Database MySQL

├── .gitignore

└── README.md

```



## Công nghệ sử dụng



- Frontend: ReactJS, Vite, Axios, React Router DOM

- Backend: Node.js, Express.js

- Database: MySQL 8.0



## Cài đặt và chạy dự án



**1. Clone repository**



```bash

git clone https://github.com/Kurumi106/IELTS-Practice-Platform.git

cd IELTS-Practice-Platform

```



**2. Cài đặt Database**



- Mở MySQL Workbench.

- Chạy file `ielts_platform.sql` để tạo database.



**3. Cấu hình Backend**



Tạo file `backend/.env`:



```env

PORT=5000

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_pass
DB_NAME=ielts_platform
DB_PORT=3306

```



Cài đặt và chạy:



```bash

cd backend

npm install

npm run dev

```



Backend: http://localhost:5000



**4. Cài đặt Frontend**



Mở terminal mới:



```bash

cd frontend

npm install

npm run dev

```



Frontend: http://localhost:5173



Repository



GitHub: https://github.com/Kurumi106/IELTS-Practice-Platform




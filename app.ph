from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///posts.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'your_secret_key_here'

db = SQLAlchemy(app)

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(255), nullable=False)
    author = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, nullable=False, default=datetime.now)

db.create_all()

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        text = request.form['text']
        author = request.form['author']
        if can_post(author):
            create_post(text, author)
        return redirect(url_for('index'))
    posts = Post.query.order_by(Post.date.desc()).all()
    return render_template('index.html', posts=posts)

@app.route('/delete/<int:post_id>', methods=['POST'])
def delete(post_id):
    post = Post.query.get(post_id)
    db.session.delete(post)
    db.session.commit()
    return redirect(url_for('index'))

def create_post(text, author):
    post = Post(text=text, author=author)
    db.session.add(post)
    db.session.commit()

def can_post(author):
    last_post = Post.query.filter_by(author=author).order_by(Post.date.desc()).first()
    if last_post:
        time_diff = datetime.now() - last_post.date
        if time_diff.total_seconds() < 600:
            return False
    return True

if __name__ == '__main__':
    app.run(debug=True)






    

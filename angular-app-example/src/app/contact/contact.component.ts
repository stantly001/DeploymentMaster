import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-contact',
  template: `
    <div class="contact-container">
      <h1>Contact Us</h1>
      
      <div class="contact-content">
        <div class="contact-info">
          <h2>Get in Touch</h2>
          <p>
            Have questions about deploying Angular applications with Nginx?
            Want to learn more about our deployment solutions? Send us a message
            and we'll get back to you as soon as possible.
          </p>
          
          <div class="info-item">
            <div class="icon">📧</div>
            <div class="text">
              <h3>Email</h3>
              <p>info@example.com</p>
            </div>
          </div>
          
          <div class="info-item">
            <div class="icon">📞</div>
            <div class="text">
              <h3>Phone</h3>
              <p>+1 (555) 123-4567</p>
            </div>
          </div>
          
          <div class="info-item">
            <div class="icon">📍</div>
            <div class="text">
              <h3>Address</h3>
              <p>123 Tech Street, Web City, WC 12345</p>
            </div>
          </div>
        </div>
        
        <div class="contact-form">
          <h2>Send us a message</h2>
          
          <form [formGroup]="contactForm" (ngSubmit)="onSubmit()">
            <div class="form-group" [ngClass]="{'error': submitted && f.name.errors}">
              <label for="name">Name</label>
              <input 
                type="text" 
                id="name" 
                formControlName="name" 
                [ngClass]="{'invalid': submitted && f.name.errors}"
              >
              <div *ngIf="submitted && f.name.errors" class="error-message">
                <span *ngIf="f.name.errors.required">Name is required</span>
              </div>
            </div>
            
            <div class="form-group" [ngClass]="{'error': submitted && f.email.errors}">
              <label for="email">Email</label>
              <input 
                type="email" 
                id="email" 
                formControlName="email" 
                [ngClass]="{'invalid': submitted && f.email.errors}"
              >
              <div *ngIf="submitted && f.email.errors" class="error-message">
                <span *ngIf="f.email.errors.required">Email is required</span>
                <span *ngIf="f.email.errors.email">Please enter a valid email address</span>
              </div>
            </div>
            
            <div class="form-group" [ngClass]="{'error': submitted && f.subject.errors}">
              <label for="subject">Subject</label>
              <input 
                type="text" 
                id="subject" 
                formControlName="subject" 
                [ngClass]="{'invalid': submitted && f.subject.errors}"
              >
              <div *ngIf="submitted && f.subject.errors" class="error-message">
                <span *ngIf="f.subject.errors.required">Subject is required</span>
              </div>
            </div>
            
            <div class="form-group" [ngClass]="{'error': submitted && f.message.errors}">
              <label for="message">Message</label>
              <textarea 
                id="message" 
                formControlName="message" 
                rows="5"
                [ngClass]="{'invalid': submitted && f.message.errors}"
              ></textarea>
              <div *ngIf="submitted && f.message.errors" class="error-message">
                <span *ngIf="f.message.errors.required">Message is required</span>
                <span *ngIf="f.message.errors.minlength">Message must be at least 20 characters</span>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="submit" class="btn primary" [disabled]="loading">
                <span *ngIf="loading">Sending...</span>
                <span *ngIf="!loading">Send Message</span>
              </button>
              <button type="button" class="btn secondary" (click)="resetForm()" [disabled]="loading">
                Reset
              </button>
            </div>
            
            <div *ngIf="success" class="success-message">
              Your message has been sent successfully! We'll get back to you soon.
            </div>
          </form>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .contact-container {
      max-width: 100%;
      padding: 0 1rem;
    }
    
    h1 {
      margin-bottom: 2rem;
      color: #3f51b5;
      font-size: 2.5rem;
      font-weight: 700;
      border-bottom: 2px solid #f0f0f0;
      padding-bottom: 0.5rem;
    }
    
    .contact-content {
      display: grid;
      grid-template-columns: 1fr 2fr;
      gap: 3rem;
      margin-bottom: 3rem;
    }
    
    .contact-info, .contact-form {
      background-color: #f9f9f9;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
    }
    
    .contact-info {
      align-self: start;
    }
    
    h2 {
      color: #333;
      font-size: 1.8rem;
      margin-bottom: 1.5rem;
    }
    
    h3 {
      color: #3f51b5;
      font-size: 1.2rem;
      margin: 0 0 0.3rem;
    }
    
    p {
      line-height: 1.7;
      margin-bottom: 1.5rem;
      color: #444;
    }
    
    .info-item {
      display: flex;
      align-items: flex-start;
      margin-bottom: 1.5rem;
    }
    
    .icon {
      font-size: 1.8rem;
      margin-right: 1rem;
      color: #3f51b5;
    }
    
    .text p {
      margin-bottom: 0;
    }
    
    .form-group {
      margin-bottom: 1.5rem;
    }
    
    label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 500;
      color: #333;
    }
    
    input, textarea {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 1rem;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    
    input:focus, textarea:focus {
      border-color: #3f51b5;
      box-shadow: 0 0 0 2px rgba(63, 81, 181, 0.2);
      outline: none;
    }
    
    .invalid {
      border-color: #f44336;
    }
    
    .error-message {
      color: #f44336;
      font-size: 0.85rem;
      margin-top: 0.5rem;
    }
    
    .success-message {
      background-color: #e8f5e9;
      color: #2e7d32;
      padding: 1rem;
      border-radius: 4px;
      margin-top: 1.5rem;
      font-weight: 500;
    }
    
    .form-actions {
      display: flex;
      gap: 1rem;
    }
    
    .btn {
      padding: 0.75rem 1.5rem;
      border-radius: 4px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.3s;
      border: none;
    }
    
    .primary {
      background-color: #3f51b5;
      color: white;
    }
    
    .primary:hover:not([disabled]) {
      background-color: #303f9f;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    
    .secondary {
      background-color: #f5f5f5;
      color: #333;
    }
    
    .secondary:hover:not([disabled]) {
      background-color: #e0e0e0;
    }
    
    button[disabled] {
      opacity: 0.6;
      cursor: not-allowed;
    }
    
    @media (max-width: 768px) {
      .contact-content {
        grid-template-columns: 1fr;
        gap: 2rem;
      }
      
      h1 {
        font-size: 2rem;
      }
      
      .contact-info, .contact-form {
        padding: 1.5rem;
      }
    }
  `]
})
export class ContactComponent {
  contactForm: FormGroup;
  loading = false;
  submitted = false;
  success = false;
  
  constructor(private formBuilder: FormBuilder) {
    this.contactForm = this.formBuilder.group({
      name: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      subject: ['', Validators.required],
      message: ['', [Validators.required, Validators.minLength(20)]]
    });
  }
  
  // Getter for easy access to form fields
  get f() { return this.contactForm.controls; }
  
  onSubmit() {
    this.submitted = true;
    
    // Stop here if form is invalid
    if (this.contactForm.invalid) {
      return;
    }
    
    this.loading = true;
    
    // Simulate API call
    setTimeout(() => {
      this.success = true;
      this.loading = false;
      // Reset form after successful submission
      this.contactForm.reset();
      this.submitted = false;
    }, 1500);
  }
  
  resetForm() {
    this.contactForm.reset();
    this.submitted = false;
    this.success = false;
  }
}
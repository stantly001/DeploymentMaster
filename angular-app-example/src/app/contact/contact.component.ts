import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-contact',
  template: `
    <div class="contact-container">
      <h1>Contact Us</h1>
      <div class="contact-content">
        <div class="contact-form-container">
          <h2>Send us a message</h2>
          <form [formGroup]="contactForm" (ngSubmit)="onSubmit()">
            <div class="form-group">
              <label for="name">Name</label>
              <input 
                type="text" 
                id="name" 
                formControlName="name" 
                [ngClass]="{'invalid': submitted && f.name.errors}"
              >
              <div *ngIf="submitted && f.name.errors" class="error-message">
                <div *ngIf="f.name.errors.required">Name is required</div>
              </div>
            </div>
            
            <div class="form-group">
              <label for="email">Email</label>
              <input 
                type="email" 
                id="email" 
                formControlName="email"
                [ngClass]="{'invalid': submitted && f.email.errors}"
              >
              <div *ngIf="submitted && f.email.errors" class="error-message">
                <div *ngIf="f.email.errors.required">Email is required</div>
                <div *ngIf="f.email.errors.email">Email is invalid</div>
              </div>
            </div>
            
            <div class="form-group">
              <label for="subject">Subject</label>
              <input 
                type="text" 
                id="subject" 
                formControlName="subject"
                [ngClass]="{'invalid': submitted && f.subject.errors}"
              >
              <div *ngIf="submitted && f.subject.errors" class="error-message">
                <div *ngIf="f.subject.errors.required">Subject is required</div>
              </div>
            </div>
            
            <div class="form-group">
              <label for="message">Message</label>
              <textarea 
                id="message" 
                rows="5" 
                formControlName="message"
                [ngClass]="{'invalid': submitted && f.message.errors}"
              ></textarea>
              <div *ngIf="submitted && f.message.errors" class="error-message">
                <div *ngIf="f.message.errors.required">Message is required</div>
                <div *ngIf="f.message.errors.minlength">Message must be at least 10 characters</div>
              </div>
            </div>
            
            <button type="submit" class="submit-button" [disabled]="loading">
              <span *ngIf="loading">Sending...</span>
              <span *ngIf="!loading">Send Message</span>
            </button>
            
            <div *ngIf="submitted && success" class="success-message">
              Your message has been sent successfully!
            </div>
          </form>
        </div>
        
        <div class="contact-info">
          <h2>Contact Information</h2>
          <div class="info-item">
            <strong>Address:</strong>
            <p>123 Angular Street, Web City, 94103</p>
          </div>
          <div class="info-item">
            <strong>Phone:</strong>
            <p>+1 (555) 123-4567</p>
          </div>
          <div class="info-item">
            <strong>Email:</strong>
            <p>info@example.com</p>
          </div>
          <div class="info-item">
            <strong>Hours:</strong>
            <p>Monday-Friday: 9AM - 5PM</p>
            <p>Saturday-Sunday: Closed</p>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .contact-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 1rem;
    }
    
    h1 {
      color: #3f51b5;
      margin-bottom: 2rem;
    }
    
    h2 {
      color: #3f51b5;
      margin-top: 0;
      margin-bottom: 1.5rem;
    }
    
    .contact-content {
      display: grid;
      grid-template-columns: 3fr 2fr;
      gap: 2rem;
    }
    
    @media (max-width: 768px) {
      .contact-content {
        grid-template-columns: 1fr;
      }
    }
    
    .form-group {
      margin-bottom: 1.5rem;
    }
    
    label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 500;
    }
    
    input,
    textarea {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 1rem;
    }
    
    input.invalid,
    textarea.invalid {
      border-color: #f44336;
    }
    
    .error-message {
      color: #f44336;
      font-size: 0.875rem;
      margin-top: 0.25rem;
    }
    
    .success-message {
      color: #4caf50;
      margin-top: 1rem;
      padding: 0.75rem;
      background-color: rgba(76, 175, 80, 0.1);
      border-radius: 4px;
    }
    
    .submit-button {
      background-color: #3f51b5;
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 4px;
      font-size: 1rem;
      cursor: pointer;
      transition: background-color 0.3s;
    }
    
    .submit-button:hover:not(:disabled) {
      background-color: #303f9f;
    }
    
    .submit-button:disabled {
      background-color: #9e9e9e;
      cursor: not-allowed;
    }
    
    .info-item {
      margin-bottom: 1.5rem;
    }
    
    .info-item strong {
      display: block;
      margin-bottom: 0.5rem;
      color: #3f51b5;
    }
    
    .info-item p {
      margin: 0;
      line-height: 1.5;
    }
    
    .contact-info {
      background-color: #f5f5f5;
      padding: 2rem;
      border-radius: 8px;
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
      message: ['', [Validators.required, Validators.minLength(10)]]
    });
  }
  
  // convenience getter for easy access to form fields
  get f() { return this.contactForm.controls; }
  
  onSubmit() {
    this.submitted = true;
    
    // stop here if form is invalid
    if (this.contactForm.invalid) {
      return;
    }
    
    this.loading = true;
    
    // Simulate API call
    setTimeout(() => {
      this.success = true;
      this.loading = false;
      this.contactForm.reset();
      this.submitted = false;
      
      // Reset success message after 5 seconds
      setTimeout(() => {
        this.success = false;
      }, 5000);
    }, 1500);
  }
}
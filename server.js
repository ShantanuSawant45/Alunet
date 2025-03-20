// Add this endpoint to your existing server.js

// API endpoint to save alumni data
app.post('/api/alumni', (req, res) => {
  const {
    full_name,
    email,
    phone_number,
    address,
    city,
    country,
    graduation_year,
    degree,
    major,
    current_company,
    designation,
    years_of_experience,
    linkedin_url,
    twitter_url,
    github_url,
    skills,
    bio
  } = req.body;

  const query = `
    INSERT INTO alumni (
      full_name, email, phone_number, address, city, country, graduation_year,
      degree, major, current_company, designation, years_of_experience,
      linkedin_url, twitter_url, github_url, skills, bio
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.query(query, [
    full_name, email, phone_number, address, city, country, graduation_year,
    degree, major, current_company, designation, years_of_experience,
    linkedin_url, twitter_url, github_url, skills, bio
  ], (err, result) => {
    if (err) {
      console.error('Error inserting data:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.status(201).json({ message: 'Alumni data saved successfully' });
  });
}); 
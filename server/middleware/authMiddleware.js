const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
  const token = req.header("x-auth-token");

  // Check if token is provided
  if (!token) {
    return res.status(401).json({ msg: "No token, authorization denied" });
  }

  console.log("Token:", token);

  try {
    // Verify token and decode it
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log("Decoded:", decoded);
    req.user = decoded; // Attach user info to the request object
    next(); // Proceed to the next middleware or route handler
  } catch (err) {
    // Handle token verification errors
    console.error("Token verification error:", err.message);

    // Check if the error is due to token expiration
    if (err.name === "jwt expired") {
      return res.status(401).json({ msg: "Token has expired" });
    }

    // For other errors, respond with a generic message
    return res.status(400).json({ msg: "Token is not valid" });
  }
};

module.exports = authMiddleware;

import { Router } from "express";
const router = Router();
router.post("/enable", (req, res) => res.json({ enabled: true }));
export default router;

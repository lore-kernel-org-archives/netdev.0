From: Petri Lehtinen <petri.lehtinen@inoi.fi>
Subject: [stable] Please apply ucc_geth driver fixes to 2.6.32-stable
Date: Tue, 22 Jun 2010 16:02:29 +0300
Message-ID: <1277211752-14265-1-git-send-email-petri.lehtinen@inoi.fi>
Cc: stable@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(I already sent these patches a few weeks ago and got no reply. I also
sent them to some of the recipients a few minutes ago and failed to
use git-send-email properly. So sorry for the noise.)

Please include the following three patches to 2.6.32-stable. They fix
serious flaws in the ucc_geth ethernet driver, making it unusable (at
least on my system).

They have been included in 2.6.33 and apply cleanly on top of
2.6.32-stable.

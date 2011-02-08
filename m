From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: compat-wireless for 2.6.38-rc3 - third release
Date: Mon, 7 Feb 2011 17:10:49 -0800
Message-ID: <AANLkTineqSLDLg84Ah7Djd1R=K-xTfQDUd==K+eaJFES@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
To: linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I updated compat-wireless for 2.6.38-rc3, this is the third update, it
should now include the proper compat.git branch and also adds some new
patches from Hauke to minimize deltas and fix compilation. While at it
I took the time to suck in new pending-stable patches for an "-s"
release, I haven't cherry picked any patches yet as I cannot think of
anything immediately important, if you do send me a patch.

Code metrics for the vanilla release:

    782535 - Total upstream lines of code being pulled
      2108 - backport code changes
      1847 - backport code additions
       261 - backport code deletions
      7292 - backport from compat module
      9400 - total backport code
    1.2012 - % of code consists of backport work

Base tree: linux-2.6-allstable.git
Base tree version: v2.6.38-rc3
compat-wireless release: compat-wireless-v2.6.38-rc3-3

Code metrics for the "-s" release:

    782535 - Total upstream lines of code being pulled
      2108 - backport code changes
      1847 - backport code additions
       261 - backport code deletions
      7292 - backport from compat module
      9400 - total backport code
    1.2012 - % of code consists of backport work
       115 - Code changes brought in from pending-stable
        57 - Code additions brought in from pending-stable
        58 - Code deletions brought in from pending-stable
    0.0147 - % of code being cherry picked from pending-stable

Base tree: linux-2.6-allstable.git
Base tree version: v2.6.38-rc3
compat-wireless release: compat-wireless-v2.6.38-rc3-3-s

Relevant URLs:

http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/compat-wireless-2.6.38-rc3-3.tar.bz2
http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/compat-wireless-2.6.38-rc3-3-s.tar.bz2
http://www.orbit-lab.org/kernel/compat-wireless-2.6-stable/v2.6.38/ChangeLog-2.6.38-wireless
http://wireless.kernel.org/en/users/Download/stable

  Luis

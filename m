From: Frank Sorenson <frank@tuxrocks.com>
Subject: Mouse issues in -mm
Date: Wed, 23 Nov 2005 19:06:38 -0700
Message-ID: <4385202E.70404@tuxrocks.com>
References: <20051123033550.00d6a6e8.akpm@osdl.org>	<20051123175045.GA6760@stiffy.osknowledge.org> <20051123113854.07fca702.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Koschewski <marc@osknowledge.org>,
	linux-kernel@vger.kernel.org, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750959AbVKXCGz@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20051123113854.07fca702.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
> Marc Koschewski <marc@osknowledge.org> wrote:
>>Just booted into 2.6.15-rc2-mm1. The 'mouse problem' (as reported earlier) still
>>persists,
> 
> You'l probably need to re-report the mouse problem if the previous report
> didn't get any action.

I'm not certain whether this is the same 'mouse problem', but I'll
report the mouse problems I've been seeing.  In the past several -mm
kernels, my touchpad has initially worked at boot, but 'tapping' has
stopped working at some point later (with no obvious kernel messages).

I've experienced this problem at least with 2.6.15-rc1-mm2 and
2.6.15-rc2-mm1, and reverting
input-attempt-to-re-synchronize-mouse-every-5-seconds.patch gives a
kernel without the touchpad problems.

Thanks,

Frank
- --
Frank Sorenson - KD7TZK
Systems Manager, Computer Science Department
Brigham Young University
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFDhSAuaI0dwg4A47wRAvzYAJ94ifBDBTm7MfVsbTOZE8QG3NjZUwCggHv0
SQvehLxz6pLHs+5J+jTeaKU=
=Pkg2
-----END PGP SIGNATURE-----

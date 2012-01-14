From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Sat, 14 Jan 2012 13:22:22 +0100
Message-ID: <20120114122222.GA21233@nautica>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Arend van Spriel <arend@broadcom.com>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:34006 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754350Ab2ANMao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jan 2012 07:30:44 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry to hijack this thread, but I had the exact same problem Arend has
and disabling MCE fixed it.. Since it froze only after resume and it
didn't send anything to netconsole at this moment I've had this for some
time without any good debug info, so first is a thank you!

I'd like to try if the fix in current -git works, could you remind me
the exact tree name you call this?
I'm familiar with linux-2.6.git, wireless-testing.git, and
linux-next.git, but it's not resolved in linux-next.git not
linux-2.6.git's HEAD at the very least.

By the way, resume/suspend works with your patches over linux-next.git
with a bcm4313 on a eeepc1215b!

Regards,

-- 
Dominique Martinet | Asmadeus

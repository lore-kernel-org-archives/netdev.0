From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: 2.6.33-rc2: Reported regressions 2.6.31 -> 2.6.32
Date: Tue, 29 Dec 2009 16:47:35 +0100
Message-ID: <4B3A2497.1030506@gmail.com>
References: <oBElxfTZdhL.A.bx.-vhOLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753204AbZL2Prl@vger.kernel.org>
In-Reply-To: <oBElxfTZdhL.A.bx.-vhOLB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafael,

On 12/29/09 16:26, Rafael J. Wysocki wrote:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14896
> Subject		: REGRESSION for RT2561/RT61 in 2.6.32, related to power saving
> Submitter	: Alan Stern <stern@rowland.harvard.edu>
> Date		: 2009-12-06 22:12 (24 days old)
> References	: http://marc.info/?l=linux-kernel&m=126013756829691&w=4
> Handled-By	: Gertjan van Wingerde <gwingerde@gmail.com>
> 

This one is fixed via a patch that is queued to be merged into 2.6.33. Is submitted
for stable as well.
See http://marc.info/?l=linux-wireless&m=126090994909576&w=2

> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14731
> Subject		: rt61pci regression
> Submitter	: tim blechmann <tim@klingt.org>
> Date		: 2009-12-04 09:33 (26 days old)
> 

I believe this problem to be the same as the previous one, and the fix indicated above
should fix this as well.
Note however that the submitter had presumably unrelated issues that caused him not to 
be able to validate the workaround of disabling powersaving.

---
Gertjan.

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Wed, 07 Mar 2007 06:06:37 -0500
Message-ID: <45EE9CBD.9040807@garzik.org>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org> <20070305015031.GF3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sid Boyce <g3vbv@blueyonder.co.uk>,
	Pavel Machek <pavel@ucw.cz>,
	Marcel Holtmann <marcel@holtmann.org>, linux-pm@lists.osdl.org,
	maxk@qualcomm.com, bluez-devel@lists.sf.net,
	Mark Lord <lkml@rtr.ca>, Greg KH <greg@kroah.com>,
	Matt Mackall <mpm@selenic.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422725AbXCGLHe@vger.kernel.org>
In-Reply-To: <20070305015031.GF3441@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Subject    : forcedeth: skb_over_panic
> References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
> Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
> Status     : unknown


I think this is fixed by the recent forcedeth 3-patch patchset?  Can 
Albert or others confirm?

	Jeff

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Mon, 11 Sep 2006 18:04:01 -0400
Message-ID: <4505DD51.5090000@garzik.org>
References: <45021D4A.6040805@lwfinger.net> <20060909152305.GA27080@tuxdriver.com> <4502E62B.5060601@lwfinger.net> <20060911192846.GB19326@tuxdriver.com> <4505C005.2070302@lwfinger.net> <20060911203458.GD19326@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>, Michael Buesch <mb@bu3sch.de>,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14018 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932154AbWIKWEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 18:04:08 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060911203458.GD19326@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Mon, Sep 11, 2006 at 02:59:01PM -0500, Larry Finger wrote:
>> John W. Linville wrote:
> 
>>> Also, if you could just use "---" instead of a long line of "======",
>>> I think I would have to do less manual processing...thanks!
>> Sorry about the === rather than ---. Is that documented somewhere?
> 
> Not too explicitly, but I think Andrew mentions it in "The Perfect Patch":
> 
> 	http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt
> 
> While you are looking, you might review Jeff's version of the same idea:
> 
> 	http://linux.yyz.us/patch-format.html

And also Documentation/SubmittingPatches, which ATM seems to have more 
detail than either page.

	Jeff




From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH] linux-firmware: Add a new bnx2x FW 7.0.20.0
Date: Tue, 14 Jun 2011 12:57:40 +0300
Message-ID: <201106141257.40621.vladz@broadcom.com>
References: <201106141241.40764.vladz@broadcom.com>
 <1308044887.3450.4.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2109 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755902Ab1FNJ60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 05:58:26 -0400
In-Reply-To: <1308044887.3450.4.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 June 2011 12:48:06 David Woodhouse wrote:
> On Tue, 2011-06-14 at 12:41 +0300, Vlad Zolotarov wrote:
> > 
> >  bnx2x/bnx2x-e1-7.0.20.0.fw.ihex  |10075 +++++++++++++++++++++
> >  bnx2x/bnx2x-e1h-7.0.20.0.fw.ihex |10538 ++++++++++++++++++++++
> >  bnx2x/bnx2x-e2-7.0.20.0.fw.ihex  |18190 ++++++++++++++++++++++++++++++++++++++
> 
> You haven't tested this, have you?

What do u mean? I do have put the ihex files under the net-next kernel tree at the regular location plus I updated the the kernel's firmware/WHENCE and firmware/Makefile files and of course I ran a functionality tests for the driver after all patches and with the new firmware.

If u meant the different sort of testing, pls., clarify.

> 
> Add the binary file, not an ihex version.

I'll resend the binary files. 

thanks,
vlad

> 
> 


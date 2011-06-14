From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH] linux-firmware: Add a new bnx2x FW 7.0.20.0
Date: Tue, 14 Jun 2011 13:53:34 +0300
Message-ID: <201106141353.34962.vladz@broadcom.com>
References: <201106141241.40764.vladz@broadcom.com>
 <201106141310.16440.vladz@broadcom.com>
 <1308046604.3450.7.camel@i7.infradead.org>
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
Received: from mms2.broadcom.com ([216.31.210.18]:1916 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845Ab1FNKy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 06:54:26 -0400
In-Reply-To: <1308046604.3450.7.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 June 2011 13:16:43 David Woodhouse wrote:
> On Tue, 2011-06-14 at 13:10 +0300, Vlad Zolotarov wrote:
> > 
> > Aha... Correct me if I got u wrong: to test it I need to manually copy
> > the new .fw files into the /lib/firmware directory, install the clean
> > net-next kernel with the driver that supports this new FW and it
> > should work. Is it what u meant?
> 
> Right. Imagine that you have checked out the linux-firmware.git
> repository directly into /lib/firmware, and nothing else has been
> written there.

Got it. I checked it now and surprizingly it worked... ;)

thanks, man. 

I'm resending u *binaries* ...

> 
> 


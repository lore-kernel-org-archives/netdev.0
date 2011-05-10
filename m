From: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Subject: Re: [PATCH 1/5] ssb: Change fallback sprom to callback mechanism.
Date: Tue, 10 May 2011 17:28:06 +0200
Message-ID: <1305041286.29322.2.camel@maggie>
References: <1304771263-10937-1-git-send-email-hauke@hauke-m.de>
	 <1304771263-10937-2-git-send-email-hauke@hauke-m.de>
	 <BANLkTinV+cuTr2cPvR2pBDE_C-2J4KwWcA@mail.gmail.com>
	 <20110510152711.GA26759@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonas Gorski <jonas.gorski@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>, linux-mips@linux-mips.org,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 80-190-117-144.ip-home.de ([80.190.117.144]:54705 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755501Ab1EJP2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 11:28:16 -0400
In-Reply-To: <20110510152711.GA26759@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-10 at 16:27 +0100, Ralf Baechle wrote: 
> On Sat, May 07, 2011 at 07:24:18PM +0200, Jonas Gorski wrote:
> 
> > just some small small spelling nit-picks:
> 
> > > CC: Michael Buesch <mb@bu3sch.de>
> > > CC: netdev@vger.kernel.org
> > > CC: Florian Fainelli <florian@openwrt.org>
> > > Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> 
> Michael,
> 
> can I have an Ack for this patch assuming the raised spelling issues will
> get fixed?  Thanks,

I'd still prefer a platform-data based mechanism, but this would
be much more intrusive.
So yeah. ACK, for the time being.

-- 
Greetings Michael.


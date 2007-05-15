From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: tg3 does not want to go up (config space problems).
Date: Tue, 15 May 2007 08:16:56 +0400
Message-ID: <20070515041656.GA3554@2ka.mipt.ru>
References: <20070514145419.GA19679@2ka.mipt.ru> <1179162923.25622.22.camel@dell> <1179170434.25622.29.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57112 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016AbXEOERD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 00:17:03 -0400
Content-Disposition: inline
In-Reply-To: <1179170434.25622.29.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 12:20:34PM -0700, Michael Chan (mchan@broadcom.com) wrote:
> > > This problem never happend before, but suddenly appeared after quite
> > > long suspend to disk (several month I think).
> > > Nothing was changed in hardware.
> > > Both 2.6.18 and 2.6.21-rc3 have the same issue.
> > > No interrupts reported in /proc/interrupts.
> > 
> > I'll look into this.  Thanks.
> > 
> 
> Suspend/resume worked fine for me on 2.6.21.1 on a similar 5705 device.
> I only suspended for a few minutes to mem though.  Does this problem
> only happen after a long suspend?

It worked before too - I suspended with 2.6.18 many times.
This problem happend after quite long suspend.

-- 
	Evgeniy Polyakov

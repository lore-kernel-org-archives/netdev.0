From: Sam <miaousami@hotmail.com>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Wed, 8 Jan 2014 22:53:58 +0000 (UTC)
Message-ID: <loom.20140108T235222-960@post.gmane.org>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com> <20130805225752.14e843f7@nehalam.linuxnetplumber.net> <CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com> <1375785799.4457.81.camel@edumazet-glaptop> <1375788758.8219.13.camel@jlt4.sipsolutions.net> <1375790821.4457.90.camel@edumazet-glaptop> <CACtZaF+aamW_0P2O1zSGLWHmichAZKb96pC4GCCVZZXJsh8Y7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:34978 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757758AbaAHXAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 18:00:11 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1W126W-0003Ji-By
	for netdev@vger.kernel.org; Thu, 09 Jan 2014 00:00:04 +0100
Received: from ras75-9-83-157-52-228.fbx.proxad.net ([83.157.52.228])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 00:00:04 +0100
Received: from miaousami by ras75-9-83-157-52-228.fbx.proxad.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 00:00:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kinley Dorji <kinleyd <at> gmail.com> writes:

> 
>  <at> Johannes Berg: > don't really care much for the
> > stats in the system I'm using this device on - and based on the driver
> > I'm not sure I'd use the chip for 'serious' work anyway :)
> 
> OTOH, conky users love having the stats up, even if they aren't precise. :)
> 
> There's one other point:
> 
> Before the mainlining of the alx drivers, the default settings for
> Wake-on used to be d, whereas now it seems to be pg. This startled me
> a couple of times with my computer turning on unexpectedly, having
> been used to the previous defaults. Just FYI.
> 
> Other than that, I would like thank you all very much for your quick
> responses and I look forward to having the stats code restored to the
> alx drivers.
> 
> With best regards,
> 
> Kinley
> 


Hi guys,

I am experiencing this bug on a 3.11 kernel.
Can you tell me if the fix has been released upstream? in which kernel version?

Thanks
Regards

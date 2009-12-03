From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Thu, 03 Dec 2009 09:29:54 -0500
Message-ID: <1259850594.3766.46.camel@bigi>
References: <1259585129.3992.13.camel@nienna.balabit>
	 <1259589577.873.30.camel@bigi> <1259674488.3168.45.camel@bigi>
	 <20091202.223117.228943068.davem@davemloft.net>
	 <1259848398.3766.43.camel@bigi>  <4B17C346.3000906@trash.net>
	 <1259849264.13245.3.camel@nienna.balabit>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:39566 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZLCO3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 09:29:51 -0500
Received: by vws30 with SMTP id 30so623758vws.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 06:29:57 -0800 (PST)
In-Reply-To: <1259849264.13245.3.camel@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-03 at 15:07 +0100, KOVACS Krisztian wrote:
> Hi,
> 
> On Thu, 2009-12-03 at 14:55 +0100, Patrick McHardy wrote:

> > Agreed, the accept_local sysctl should not be misused for this,
> > otherwise TPROXY setups wouldn't have source validation anymore.
> 
> Absolutely agreed.
> 

Ok, thanks.
Dave - i can resubmit on top of Patricks changes once you swallow them.
Or if you consider this a bug fix then i could submit before Patrick's
(which is essentially that patch). 
Let me know.

cheers,
jamal



From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 5 Jan 2005 06:30:11 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0501050627050.27046@hibernia.jakma.org>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
  <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
 <1104895169.1117.63.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1104895169.1117.63.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Jan 2005, jamal wrote:

> Theres possibly people who would want it differently - so for we 
> havent heard from them. Maybe poll far and wide - or push it in and 
> wait for them to whine.

We're whining.

This policy in the Linux kernel makes using Linux dangerous for 
certain routing applications (RIP, routing advertisements).

Name a non-TCP application that *does* want this newish kernel policy 
and tell me how it breaks without this *new* policy. ;)

> cheers,
> jamal

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
My only love sprung from my only hate!
Too early seen unknown, and known too late!
 		-- William Shakespeare, "Romeo and Juliet"

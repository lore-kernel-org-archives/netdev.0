From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Fri, 10 Dec 2004 15:37:15 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0412101536160.16016@hibernia.jakma.org>
References: <E1CbTv3-000732-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Hasso Tepper <hasso@estpak.ee>, hadi@cyberus.ca,
        thomas.spatzier@de.ibm.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CbTv3-000732-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Dec 2004, Herbert Xu wrote:

> I don't see why this should be happening.

Thomas' original patch was to address this problem. I wonder could he 
recap the kernel side of this problem?

> Can you please provide a minimal program that reproduces this 
> blocking problem? For example, something that sends a packet to a 
> downed interface and then sends one to an interface that's up?

I will try get this for you soon.

regards
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
Who was that masked man?

From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 06 Jan 2005 08:55:58 -0500
Message-ID: <1105019757.2314.16.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0501050627050.27046@hibernia.jakma.org>
	 <1104931011.1118.134.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0501051408330.27046@hibernia.jakma.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.61.0501051408330.27046@hibernia.jakma.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 09:29, Paul Jakma wrote:
> On Wed, 5 Jan 2005, jamal wrote:

[..]
> Sorry, wires crossed re "new behaviour". The "new new" behaviour in 
> the patch as you describe would be perfect.
> 
> PS: Another issue, could we have kernel space IP fragmentation for 
> IP_HDRINCL sockets please? We currently have to implement 
> fragmentation ourselves, which seems silly given that kernel already 
> has this functionality.

I will let some other fireman grab this bait ;-> 
If not i will revisit it after a unknown/random timeout.

cheers,
jamal

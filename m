From: "Harish Kulkarni" <hari@cosystech.com>
Subject: Network Device-Driver/Layer Implementation: Help required
Date: Thu, 31 Oct 2002 13:25:18 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <NFBBKDONILLOCGDCFLLIAEALCGAA.hari@cosystech.com>
References: <15808.11521.25342.659187@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <15808.11521.25342.659187@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,
I have a T1/E1 device driver: ( completed till PCI initialization and other
device-internals initialization,including interrupts handling procedures),
now i am not understanding how to provide the interface to upper layers?. I
have walked through the lapb-module.txt and some code of IPX, but still the
things are not clear. Can any one help/guide me?
-Thanks
Hari


> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
> Behalf Of Robert Olsson
> Sent: Thursday, October 31, 2002 12:33 AM
> To: Cheng Jin
> Cc: jamal; netdev@oss.sgi.com
> Subject: Re: Linux SMP on 2.4.18-3
>
>
>
> Cheng Jin writes:
>
>  > Out of curiosity, what is the maximum send rate (pps) under Linux
>  > 2.4.18-3?  I read in the paper that sending across two Intel
> Gbe with one
>  > CPU gets up to 36o Kpps.
>
>  Yes forwarding performance...
>
>  A good chip/driver can itself do a lot more. I have seen very
> decent numbers
>  with e1000, tg3 and dl2k. For FE tulip has been a top performer for long
>  time but  I also now see 144 kpps from my laptop w. 3c59x driver.
>
>  Cheers.
> 						--ro
>
>
>

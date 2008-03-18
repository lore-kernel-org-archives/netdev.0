From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Tue, 18 Mar 2008 17:21:56 +0300
Message-ID: <47DFD004.4000202@ru.mvista.com>
References: <1205488348-22536-1-git-send-email-sr@denx.de>	
	<47DE5F43.80604@garzik.org> <1205789101.26869.181.camel@pasglop>	
	<1205789205.26869.184.camel@pasglop>	
	<20080317164341.12075616@zod.rchland.ibm.com>	
	<1205790747.26869.187.camel@pasglop> <47DEF159.3020504@garzik.org>	
	<20080317200855.2954971a@zod.rchland.ibm.com>
	<1205808100.26869.204.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1205808100.26869.204.camel@pasglop>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
>> http://marc.info/?l=linux-netdev&m=120449748701492&w=2
>>
>> I sent it to Ben with netdev on CC because you asked the various people
>> sending NEWEMAC patches to you to find a single person.
>>
>> So from now on, what are we going to do?  It seems we're playing net
>> maintainer russian roulette for NEWEMAC and it's getting old.
> 
> I'm happy to collect the patches. I said I would do it, I was just taken
> aback a bit by Jeff suddenly merging two of Stefan patches directly :-)
> 
> I was actually planning this week to post a serie of all the pending
> EMAC patches for final review.
> 
> Cheers,
> Ben.
> 
> 

FYI, These are the NEWEMAC patches I've sent:
http://ozlabs.org/pipermail/linuxppc-dev/2008-February/052114.html
(This is a TAH csum fix, that I don't see on the patchwork for some reason)
and a couple of PHY clock workarounds
http://patchwork.ozlabs.org/linuxppc/patch?id=17211
http://patchwork.ozlabs.org/linuxppc/patch?id=17212
The latter two patches depend on the "dcri_clrset" one:
http://patchwork.ozlabs.org/linuxppc/patch?id=17199
Ben, could you please also take a look at the PCIe dcri_clrset stuff here
http://patchwork.ozlabs.org/linuxppc/patch?id=17214
(not EMAC related)
Thanks,
Valentine.

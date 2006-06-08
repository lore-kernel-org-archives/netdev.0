From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/10] Add Vitesse 8244 PHY for MPC8641 HPCN platform.
Date: Thu, 08 Jun 2006 16:36:07 -0400
Message-ID: <44888A37.3090401@garzik.org>
References: <1149720298.23938.207.camel@cashmere.sps.mot.com>	 <44887BD3.7000009@garzik.org> <1149797603.23938.251.camel@cashmere.sps.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62936 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964986AbWFHUgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 16:36:11 -0400
To: Jon Loeliger <jdl@freescale.com>
In-Reply-To: <1149797603.23938.251.camel@cashmere.sps.mot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Loeliger wrote:
> On Thu, 2006-06-08 at 14:34, Jeff Garzik wrote:
>> Jon Loeliger wrote:
>>> Signed-off-by: Kriston Carson <KristonCarson@freescale.com>
>>> Signed-off-by: Xianghua Xiao <x.xiao@freescale.com>
>>> Signed-off-by: Jon Loeliger <jdl@freescale.com>
>> ACK, but patch does not apply to netdev-2.6.git#upstream.
>>
>> 	Jeff
> 
> Thanks, Jeff.
> 
> Are you willing to take the netdev parts as-is, then?
> Or would you like me to reformat the netdev parts to
> apply against the netdev-2.6.git#upstream branch?
> The patch is currently for the Paul Mackerras powerpc.git
> tree as it stands now.  Should we apply it through that
> path now as you have ACK'ed it?

Is it dependent on other stuff in Paul's tree?

Normally this should come through netdev-2.6.git#upstream...

	Jeff




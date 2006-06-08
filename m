From: Jon Loeliger <jdl@freescale.com>
Subject: Re: [PATCH 9/10] Add Vitesse 8244 PHY for MPC8641 HPCN platform.
Date: Thu, 08 Jun 2006 15:13:28 -0500
Message-ID: <1149797603.23938.251.camel@cashmere.sps.mot.com>
References: <1149720298.23938.207.camel@cashmere.sps.mot.com>
	 <44887BD3.7000009@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58622 "EHLO
	az33egw02.freescale.net") by vger.kernel.org with ESMTP
	id S964976AbWFHURg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 16:17:36 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44887BD3.7000009@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-08 at 14:34, Jeff Garzik wrote:
> Jon Loeliger wrote:
> > Signed-off-by: Kriston Carson <KristonCarson@freescale.com>
> > Signed-off-by: Xianghua Xiao <x.xiao@freescale.com>
> > Signed-off-by: Jon Loeliger <jdl@freescale.com>
> 
> ACK, but patch does not apply to netdev-2.6.git#upstream.
> 
> 	Jeff

Thanks, Jeff.

Are you willing to take the netdev parts as-is, then?
Or would you like me to reformat the netdev parts to
apply against the netdev-2.6.git#upstream branch?
The patch is currently for the Paul Mackerras powerpc.git
tree as it stands now.  Should we apply it through that
path now as you have ACK'ed it?

Thanks,
jdl



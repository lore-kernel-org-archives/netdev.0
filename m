From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the probe
Date: Thu, 17 Feb 2011 11:19:01 +0100
Message-ID: <20110217101901.GA11897@electric-eye.fr.zoreil.com>
References: <483985247.35721.1297792863958.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com> <1297931060.9613.2.camel@ceranb.intra.cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, aabdulla@nvidia.com,
	Ben Hutchings <ben@decadent.org.uk>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55657 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810Ab1BQKWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 05:22:38 -0500
Content-Disposition: inline
In-Reply-To: <1297931060.9613.2.camel@ceranb.intra.cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
[...]
> Dave, Francois, is it acceptable?

Apparently both are acceptable. :o/

As a mildly convinced coward, I can not tell if it will help more applications
than it will break.

-- 
Ueimor

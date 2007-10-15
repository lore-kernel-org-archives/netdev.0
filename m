From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support
	to NEW EMAC.
Date: Tue, 16 Oct 2007 07:02:51 +1000
Message-ID: <1192482171.11795.35.camel@pasglop>
References: <20071015175717.GA4602@ru.mvista.com>
	 <4713B10B.5000607@garzik.org>
	 <20071015134813.6aacdcca@weaponx.rchland.ibm.com>
	 <4713B726.6080404@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Roland Dreier <rdreier@cisco.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34550 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbXJOVFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:05:34 -0400
In-Reply-To: <4713B726.6080404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-10-15 at 14:53 -0400, Jeff Garzik wrote:
> Roland Dreier (2):
>        ibm_new_emac: Nuke SET_MODULE_OWNER() use
>        ibm_emac: Convert to use napi_struct independent of struct
> net_device
> 

Wow, I'd have loved to be CCed at least on the last one since I was
about to do just that ... Heh.

Ben.



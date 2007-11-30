From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY
	support
Date: Fri, 30 Nov 2007 08:27:36 -0600
Message-ID: <20071130142736.GB3117@lixom.net>
References: <1196401223.5661.297518056501.qpush@grosgo> <20071130054126.39BDCDDE0A@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:51865 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbXK3OYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 09:24:12 -0500
Content-Disposition: inline
In-Reply-To: <20071130054126.39BDCDDE0A@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Nov 30, 2007 at 04:40:23PM +1100, Benjamin Herrenschmidt wrote:

> +static int m88e1111_init(struct mii_phy *phy)
> +{
> +	printk("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);

KERN_ level?


-Olof



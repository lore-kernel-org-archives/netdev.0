From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/9] [RFC] bonding updates for net-next-2.6
Date: Wed, 17 Dec 2008 19:14:29 -0800 (PST)
Message-ID: <20081217.191429.208550175.davem@davemloft.net>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36180
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751334AbYLRDO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:14:28 -0500
In-Reply-To: <20081217212827.080073908@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>
Date: Wed, 17 Dec 2008 22:28:27 +0100

> what follows are some bonding updates to 802.3ad mode.  They
> introduce the port_params struct as part of the port struct, which
> helps in handling the port parameter values in various places.

These cleanups look real nice, applied to net-next-2.6

Thanks Holger.

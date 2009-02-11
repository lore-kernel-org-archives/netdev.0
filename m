From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix: Remove adapter from adapter list in error
 path
Date: Wed, 11 Feb 2009 13:48:07 -0800 (PST)
Message-ID: <20090211.134807.77169123.davem@davemloft.net>
References: <200902111329.02954.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	ossrosch@linux.vnet.ibm.com, ossthema@de.ibm.com,
	raisch@de.ibm.com, themann@de.ibm.com, osstklei@de.ibm.com
To: hannes.hering@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56071
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755677AbZBKVsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:48:13 -0500
In-Reply-To: <200902111329.02954.hannes.hering@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Date: Wed, 11 Feb 2009 13:29:02 +0100

> Remove adapter from adapter list before freeing data structure in error path.
> 
> Signed-off-by: Hannes Hering <hering2@de.ibm.com>

Applied to net-next-2.6, thanks!

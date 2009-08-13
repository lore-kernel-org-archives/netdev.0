From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] af_ieee802154: drop IEEE802154_SIOC_ADD_SLAVE
 declaration
Date: Wed, 12 Aug 2009 20:50:45 -0700 (PDT)
Message-ID: <20090812.205045.52507904.davem@davemloft.net>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbZHMDuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 23:50:35 -0400
In-Reply-To: <1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Fri,  7 Aug 2009 16:58:36 +0400

> IEEE802154_SIOC_ADD_SLAVE was used to allocate 802.15.4 interfaces
> on the top of radio. It's not used anymore, drop it.
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

Applied to net-next-2.6

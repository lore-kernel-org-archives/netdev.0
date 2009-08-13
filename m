From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] af_ieee802154: provide dummy get/setsockopt
Date: Wed, 12 Aug 2009 20:52:31 -0700 (PDT)
Message-ID: <20090812.205231.205611350.davem@davemloft.net>
References: <1249649925-11996-5-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-6-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-7-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752302AbZHMDwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 23:52:21 -0400
In-Reply-To: <1249649925-11996-7-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Fri,  7 Aug 2009 16:58:41 +0400

> Provide dummt get/setsockopt implementations to stop these
> syscalls from oopsing on our sockets.
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

No need for me to apply this, already in the tree.

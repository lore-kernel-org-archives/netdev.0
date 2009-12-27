From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bond_3ad.c avoid possible null deref
Date: Sat, 26 Dec 2009 20:26:21 -0800 (PST)
Message-ID: <20091226.202621.258102628.davem@davemloft.net>
References: <20091223132710.GE17923@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42791
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753867AbZL0E0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:26:19 -0500
In-Reply-To: <20091223132710.GE17923@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 23 Dec 2009 15:27:10 +0200

> A few lines earlier we assume that best->slave could be either null or non-null so 
> we should check it here as well.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.

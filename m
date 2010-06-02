From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] korina: use netdev_alloc_skb_ip_align() here, too
Date: Wed, 02 Jun 2010 06:12:42 -0700 (PDT)
Message-ID: <20100602.061242.199043944.davem@davemloft.net>
References: <1275175416-21267-1-git-send-email-phil@nwl.cc>
	<20100529232348.3179F4CD57@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39890
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757606Ab0FBNMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:12:32 -0400
In-Reply-To: <20100529232348.3179F4CD57@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Sun, 30 May 2010 01:23:35 +0200

> This patch completes commit 89d71a66c40d629e3b1285def543ab1425558cd5
> which missed this spot, as it seems.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.

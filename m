From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all headers
 before an ethernet header
Date: Wed, 21 Nov 2012 15:31:25 -0500 (EST)
Message-ID: <20121121.153125.1757983463301480246.davem@davemloft.net>
References: <1353499919-28596-10-git-send-email-ordex@autistici.org>
	<20121121.125759.322762083309845086.davem@davemloft.net>
	<8108710.8oNxxR0rRd@sven-laptop.home.narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ordex@autistici.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, lindner_marek@yahoo.de,
	kevin.curtis@farsite.co.uk, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, jitendra.kalsaria@qlogic.com,
	rmody@brocade.com, andy@greyhouse.net, fubar@us.ibm.com
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab2KUUb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 15:31:28 -0500
In-Reply-To: <8108710.8oNxxR0rRd@sven-laptop.home.narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Wed, 21 Nov 2012 19:20:21 +0100

> Agree. But we should get this message also to the other guys
> 
> $ git grep pragma -- drivers/net

Good point, I've pulled your tree, thanks!

From: David Miller <davem@davemloft.net>
Subject: Re: [BUG,PATCH] XFRM: copy_to_user_kmaddress() reports local
 address twice
Date: Mon, 03 Nov 2008 01:32:59 -0800 (PST)
Message-ID: <20081103.013259.19419412.davem@davemloft.net>
References: <87vdv5uprk.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreas.steffen@strongswan.org,
	martin@strongswan.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754772AbYKCJdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 04:33:24 -0500
In-Reply-To: <87vdv5uprk.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Mon, 03 Nov 2008 10:23:27 +0100

> Stupid bug, sorry for that. Attached patch is against current net-2.6. 

Applied, thanks a lot Arnaud.

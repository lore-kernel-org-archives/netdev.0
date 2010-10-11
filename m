From: David Miller <davem@davemloft.net>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Mon, 11 Oct 2010 08:59:52 -0700 (PDT)
Message-ID: <20101011.085952.193718228.davem@davemloft.net>
References: <1286810413-30238-1-git-send-email-avagin@openvz.org>
	<4CB32FDB.4090001@msgid.tls.msk.ru>
	<1286812009.2737.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, avagin@openvz.org, stable@kernel.org,
	netdev@vger.kernel.org, krkumar2@in.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49792
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755029Ab0JKP7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 11:59:30 -0400
In-Reply-To: <1286812009.2737.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 17:46:49 +0200

> This patch was an optimization, not a bug fix.

Right, this has no business going into 2.6.32-stable at all.

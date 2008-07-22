From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make qdisc_class_hash_alloc() static
Date: Tue, 22 Jul 2008 14:20:16 -0700 (PDT)
Message-ID: <20080722.142016.197981381.davem@davemloft.net>
References: <20080722172041.GS14846@cs181140183.pp.htv.fi>
	<4886196F.2030001@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751571AbYGVVUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:20:16 -0400
In-Reply-To: <4886196F.2030001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 22 Jul 2008 19:31:27 +0200

> Adrian Bunk wrote:
> > This patch makes the needlessly global qdisc_class_hash_alloc() static.
> 
> Ack, this is not supposed to be global.

Applied.

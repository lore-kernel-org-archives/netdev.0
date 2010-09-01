From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm_user: avoid a warning with some compiler
Date: Wed, 01 Sep 2010 14:30:48 -0700 (PDT)
Message-ID: <20100901.143048.172540574.davem@davemloft.net>
References: <4C7D2598.5070400@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753305Ab0IAVac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:30:32 -0400
In-Reply-To: <4C7D2598.5070400@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 31 Aug 2010 17:54:00 +0200

> Attached is a small patch to remove a warning ("warning: ISO C90
> forbids mixed declarations and code" with gcc 4.3.2).

Applied.

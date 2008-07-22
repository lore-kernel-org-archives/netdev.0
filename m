From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] ipv6: use spin_trylock_bh
Date: Tue, 22 Jul 2008 14:34:42 -0700 (PDT)
Message-ID: <20080722.143442.54874260.davem@davemloft.net>
References: <20080722212927.937523165@vyatta.com>
	<20080722212951.706497135@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753564AbYGVVem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:34:42 -0400
In-Reply-To: <20080722212951.706497135@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 Jul 2008 14:29:30 -0700

> Now there is spin_trylock_bh, use it rather than open coding.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

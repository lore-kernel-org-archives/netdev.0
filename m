From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/9] net: fib_rules: consolidate IPv4 and DECnet
 ->default_pref() functions.
Date: Tue, 13 Apr 2010 04:06:27 -0700 (PDT)
Message-ID: <20100413.040627.147190685.davem@davemloft.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
	<1271007435-20035-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750917Ab0DMLGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:06:24 -0400
In-Reply-To: <1271007435-20035-2-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Sun, 11 Apr 2010 19:37:07 +0200

> From: Patrick McHardy <kaber@trash.net>
> 
> Both functions are equivalent, consolidate them since a following patch
> needs a third implementation for multicast routing.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This patch is fine.


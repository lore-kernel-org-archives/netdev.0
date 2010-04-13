From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/9] net: fib_rules: set family in fib_rule_hdr
 centrally
Date: Tue, 13 Apr 2010 04:06:56 -0700 (PDT)
Message-ID: <20100413.040656.112169085.davem@davemloft.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
	<1271007435-20035-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46763
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753155Ab0DMLGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:06:52 -0400
In-Reply-To: <1271007435-20035-3-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Sun, 11 Apr 2010 19:37:08 +0200

> From: Patrick McHardy <kaber@trash.net>
> 
> All fib_rules implementations need to set the family in their ->fill()
> functions. Since the value is available to the generic fib_nl_fill_rule()
> function, set it there.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks good.

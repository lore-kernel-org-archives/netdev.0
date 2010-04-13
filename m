From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 4/9] ipv4: raw: move struct raw_sock and raw_sk()
 to include/net/raw.h
Date: Tue, 13 Apr 2010 04:09:01 -0700 (PDT)
Message-ID: <20100413.040901.132997697.davem@davemloft.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
	<1271007435-20035-5-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753133Ab0DMLI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:08:57 -0400
In-Reply-To: <1271007435-20035-5-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Sun, 11 Apr 2010 19:37:10 +0200

> From: Patrick McHardy <kaber@trash.net>
> 
> A following patch will use struct raw_sock to store state for ipmr,
> so having the definitions in icmp.h doesn't fit very well anymore.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This is ok.

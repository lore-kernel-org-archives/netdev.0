From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] get rid of trie_init
Date: Sat, 12 Jan 2008 20:49:33 -0800 (PST)
Message-ID: <20080112.204933.143979843.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.056241123@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48428
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753551AbYAMEte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:49:34 -0500
In-Reply-To: <20080112064646.056241123@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:14 -0800

> trie_init is worthless it is just zeroing stuff that is already
> zero!  Move the memset() down to make it obvious.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Applied.

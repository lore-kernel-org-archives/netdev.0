From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: define needless global scoped variable static
Date: Tue, 30 Mar 2010 23:57:44 -0700 (PDT)
Message-ID: <20100330.235744.137837315.davem@davemloft.net>
References: <1269995052-10905-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, per.liden@nospam.ericsson.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45769
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab0CaG5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:57:43 -0400
In-Reply-To: <1269995052-10905-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 31 Mar 2010 02:24:12 +0200

> struct _zone *tipc_zones has local scope level and
> should defined with the correct scoping.
> 
> CC: Per Liden <per.liden@nospam.ericsson.com>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied, thanks.

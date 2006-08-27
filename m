From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove third bogus argument from NLA_PUT_FLAG
Date: Sat, 26 Aug 2006 19:18:36 -0700 (PDT)
Message-ID: <20060826.191836.36924440.davem@davemloft.net>
References: <1156503326.4090.10.camel@ux156>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65440
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750833AbWH0CSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 22:18:40 -0400
To: johannes@sipsolutions.net
In-Reply-To: <1156503326.4090.10.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 25 Aug 2006 12:55:26 +0200

> This patch removes the 'value' argument from NLA_PUT_FLAG which is
> unused anyway. The documentation comment was already correct so it
> doesn't need an update :)
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks Johannes.

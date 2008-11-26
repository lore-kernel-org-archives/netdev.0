From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1a/2] tc: propogate errors from tcf_hash_create
Date: Tue, 25 Nov 2008 21:12:40 -0800 (PST)
Message-ID: <20081125.211240.118544750.davem@davemloft.net>
References: <20081125101656.52348bdd@extreme>
	<492C43DF.1040703@trash.net>
	<20081125105727.56b7efef@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50126
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbYKZFMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:12:41 -0500
In-Reply-To: <20081125105727.56b7efef@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 25 Nov 2008 10:57:27 -0800

> Allow tcf_hash_create to return different errors on estimator failure.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

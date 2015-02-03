From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4 : Improve IEEE DCBx support, other
 minor open-lldp fixes
Date: Mon, 02 Feb 2015 18:55:20 -0800 (PST)
Message-ID: <20150202.185520.614829613850010571.davem@davemloft.net>
References: <1422667217-2610-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbBCCzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:55:21 -0500
In-Reply-To: <1422667217-2610-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Fri, 30 Jan 2015 17:20:17 -0800

> * Add support for IEEE ets & pfc api.
> * Fix bug that resulted in incorrect bandwidth percentage being returned for
>   CEE peers
> * Convert pfc enabled info from firmware format to what dcbnl expects before
>   returning
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied.

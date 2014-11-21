From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] cxgb4 : Fix DCB priority groups being returned
 in wrong order
Date: Fri, 21 Nov 2014 00:08:46 -0500 (EST)
Message-ID: <20141121.000846.725447970112747656.davem@davemloft.net>
References: <1416532306-29739-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756917AbaKUFI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 00:08:59 -0500
In-Reply-To: <1416532306-29739-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu, 20 Nov 2014 17:11:46 -0800

> Peer priority groups were being reversed, but this was missed in the previous
> fix sent out for this issue.
> 
> v2 : Previous patch was doing extra unnecessary work, result is the same.
> Please ignore previous patch
> 
> Fixes :	ee7bc3cdc270 ('cxgb4 : dcb open-lldp interop fixes')
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] SOCK: add raw6 drops counter
Date: Tue, 13 Nov 2007 20:31:41 -0800 (PST)
Message-ID: <20071113.203141.215714094.davem@davemloft.net>
References: <47397514.2070002@cn.fujitsu.com>
	<473A6792.10405@cn.fujitsu.com>
	<473A686D.9020200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60769
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755566AbXKNEbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:31:41 -0500
In-Reply-To: <473A686D.9020200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 14 Nov 2007 11:15:57 +0800

> Add raw drops counter for IPv6 in /proc/net/raw6 .
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied to net-2.6.25, but again more whitespace problems:

Adds trailing whitespace.
diff:9:		atomic_inc(&sk->sk_drops);	

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: Fix a typo in tcp_v4_do_calc_md5_hash() which
 prevents compilation
Date: Fri, 21 Dec 2007 06:04:32 -0800 (PST)
Message-ID: <20071221.060432.13817765.davem@davemloft.net>
References: <20071221134713.10228.50057.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbXLUOEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:04:33 -0500
In-Reply-To: <20071221134713.10228.50057.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 21 Dec 2007 08:47:13 -0500

> It's spelled "unsigned".
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, thanks.

I swore I did an allmodconfig test build with that change
added, looks like I didn't :-/

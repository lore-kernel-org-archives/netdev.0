From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: add missing kernel-doc for do_not_encrypt
Date: Thu, 31 Jul 2008 20:52:21 -0700 (PDT)
Message-ID: <20080731.205221.213276869.davem@davemloft.net>
References: <Pine.LNX.4.64.0807311152140.3067@shark.he.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755977AbYHADwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 23:52:21 -0400
In-Reply-To: <Pine.LNX.4.64.0807311152140.3067@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Thu, 31 Jul 2008 11:53:24 -0700 (PDT)

> Add missing kernel-doc notation to sk_buff:
> 
> Warning(linux-2.6.27-rc1-git2//include/linux/skbuff.h:345): No description found for parameter 'do_not_encrypt'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix dereference of nvdev before
 check
Date: Tue, 18 Aug 2015 20:15:18 -0700 (PDT)
Message-ID: <20150818.201518.1435904747046023813.davem@davemloft.net>
References: <1439953592-8210-1-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com
To: andschwa@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbbHSDPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 23:15:19 -0400
In-Reply-To: <1439953592-8210-1-git-send-email-andschwa@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Schwartzmeyer <andschwa@microsoft.com>
Date: Tue, 18 Aug 2015 20:06:32 -0700

> Passes static analysis by Smatch.
> 
> Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>

Applied, thanks.

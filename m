From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skbuff: size of hole is wrong in a comment
Date: Mon, 30 Sep 2013 22:32:58 -0700 (PDT)
Message-ID: <20130930.223258.187718038576421524.davem@davemloft.net>
References: <1380543401-29502-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mgorman@suse.de
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab3JAFZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:25:53 -0400
In-Reply-To: <1380543401-29502-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 30 Sep 2013 14:16:41 +0200

> Since commit c93bdd0e03e8 ("netvm: allow skb allocation to use PFMEMALLOC
> reserves"), hole size is one bit less than what is written in the comment.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.

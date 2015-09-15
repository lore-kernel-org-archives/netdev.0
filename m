From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: Refactor rtable initialization
Date: Tue, 15 Sep 2015 12:01:52 -0700 (PDT)
Message-ID: <20150915.120152.15525668086270152.davem@davemloft.net>
References: <1441227516-39692-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbbIOTBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 15:01:53 -0400
In-Reply-To: <1441227516-39692-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  2 Sep 2015 13:58:34 -0700

> All callers to rt_dst_alloc have nearly the same initialization following
> a successful allocation. Consolidate it into rt_dst_alloc.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.

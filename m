From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: replace if()/BUG with BUG_ON()
Date: Mon, 15 Jun 2015 17:12:36 -0700 (PDT)
Message-ID: <20150615.171236.163139411049619966.davem@davemloft.net>
References: <"000201d0a728$e1928230$a4b78690$@s"@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, dborkman@redhat.com, al.drozdov@gmail.com,
	viro@zeniv.linux.org.uk, eyal.birger@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: maninder1.s@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbFPAMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 20:12:37 -0400
In-Reply-To: <"000201d0a728$e1928230$a4b78690$@s"@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maninder Singh <maninder1.s@samsung.com>
Date: Mon, 15 Jun 2015 10:35:05 +0530

> Use BUG_ON(condition) instead of if(condition)/BUG()
> 
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>

Your email client corrupted this patch, making it unusable.

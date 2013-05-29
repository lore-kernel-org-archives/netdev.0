From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 2/3] vxlan: use unsigned int instead of
 unsigned
Date: Tue, 28 May 2013 23:54:29 -0700 (PDT)
Message-ID: <20130528.235429.1054496293735597448.davem@davemloft.net>
References: <1369730153-11214-1-git-send-email-amwang@redhat.com>
	<1369730153-11214-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934396Ab3E2Gya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:54:30 -0400
In-Reply-To: <1369730153-11214-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 28 May 2013 16:35:52 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> 'unsigned int' is slightly better.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.

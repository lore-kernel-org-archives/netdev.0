From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] sctp: use KMALLOC_MAX_SIZE instead of its own
 MAX_KMALLOC_SIZE
Date: Mon, 04 Mar 2013 14:14:49 -0500 (EST)
Message-ID: <20130304.141449.1630318569008015881.davem@davemloft.net>
References: <1362364107-26908-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758520Ab3CDTOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:14:51 -0500
In-Reply-To: <1362364107-26908-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  4 Mar 2013 10:28:27 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Don't definite its own MAX_KMALLOC_SIZE, use the one
> defined in mm.
> 
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.

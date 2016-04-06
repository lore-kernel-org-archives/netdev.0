From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: bcmgenet: cleanup for
 bcmgenet_xmit_frag()
Date: Wed, 06 Apr 2016 16:09:33 -0400 (EDT)
Message-ID: <20160406.160933.1548169753419689404.davem@davemloft.net>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
	<1459815001-91703-2-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbcDFUJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:09:40 -0400
In-Reply-To: <1459815001-91703-2-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon,  4 Apr 2016 17:10:00 -0700

> Add frag_size = skb_frag_size(frag) and use it when needed.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied.

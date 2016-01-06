From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] soreuseport: change consume_skb to kfree_skb
 in error case
Date: Wed, 06 Jan 2016 01:31:01 -0500 (EST)
Message-ID: <20160106.013101.571224779528590357.davem@davemloft.net>
References: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAFGbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:31:03 -0500
In-Reply-To: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue,  5 Jan 2016 10:57:13 -0500

> From: Craig Gallek <kraig@google.com>
> 
> Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Craig Gallek <kraig@google.com>

Also applied, thanks again Craig.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] Revert "Merge branch 'ipv6-overflow-arith'"
Date: Thu, 29 Oct 2015 07:03:02 -0700 (PDT)
Message-ID: <20151029.070302.1234535910395700057.davem@davemloft.net>
References: <1446034864-14022-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbbJ2NqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:46:18 -0400
In-Reply-To: <1446034864-14022-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 28 Oct 2015 13:21:03 +0100

> Linus dislikes these changes. To not hold up the net-merge let's revert
> it for now and fix the bug like Linus suggested.
> 
> This reverts commit ec3661b42257d9a06cf0d318175623ac7a660113, reversing
> changes made to c80dbe04612986fd6104b4a1be21681b113b5ac9.
> 
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.

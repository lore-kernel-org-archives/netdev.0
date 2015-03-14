From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] inet: tcp listener refactoring, part 9
Date: Sat, 14 Mar 2015 15:06:23 -0400 (EDT)
Message-ID: <20150314.150623.991982955249183472.davem@davemloft.net>
References: <1426287072-22175-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbbCNTG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 15:06:27 -0400
In-Reply-To: <1426287072-22175-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 13 Mar 2015 15:51:09 -0700

> This preliminary work pushes socket convergence a bit more:
> 
> 1) request sock ir_iif is universally set
> 
> 2) inet_diag can use common helpers to reduce LOC

Series applied, thanks Eric.

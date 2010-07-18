From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove MAX_SOCK_ADDR constant
Date: Sun, 18 Jul 2010 15:29:26 -0700 (PDT)
Message-ID: <20100718.152926.176642697.davem@davemloft.net>
References: <201007172138.GJF90644.VFOSFFMOLJHtQO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757384Ab0GRW3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 18:29:10 -0400
In-Reply-To: <201007172138.GJF90644.VFOSFFMOLJHtQO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jul 2010 21:38:05 +0900

> MAX_SOCK_ADDR is no longer used because commit 230b1839 "net: Use standard
> structures for generic socket address structures." replaced
> "char address[MAX_SOCK_ADDR];" with "struct sockaddr_storage address;".
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Applied, thanks.

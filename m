From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/tcp.c: Fix use of PULLHUP instead of POLLHUP
 in comments.
Date: Wed, 16 Jul 2008 20:13:52 -0700 (PDT)
Message-ID: <20080716.201352.167490585.davem@davemloft.net>
References: <1216222235-11338-1-git-send-email-will.newton@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	will.newton@gmail.com
To: will.newton@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753373AbYGQDNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:13:53 -0400
In-Reply-To: <1216222235-11338-1-git-send-email-will.newton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Newton <will.newton@imgtec.com>
Date: Wed, 16 Jul 2008 16:30:35 +0100

> Change PULLHUP to POLLHUP in tcp_poll comments and clean up another
> comment for grammar and coding style.
> 
> Signed-off-by: Will Newton <will.newton@gmail.com>

Applied, thanks.

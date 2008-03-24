From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP]: Replace char msg[] with static const char[].
Date: Sun, 23 Mar 2008 22:46:43 -0700 (PDT)
Message-ID: <20080323.224643.239044208.davem@davemloft.net>
References: <1206015994-13362-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753509AbYCXFqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:46:43 -0400
In-Reply-To: <1206015994-13362-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 20 Mar 2008 13:26:34 +0100

> 133886    2004     220  136110   213ae sctp.new/sctp.o
> 134018    2004     220  136242   21432 sctp.old/sctp.o
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.

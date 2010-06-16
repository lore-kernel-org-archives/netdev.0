From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip_frag: Remove some atomic ops
Date: Tue, 15 Jun 2010 18:13:01 -0700 (PDT)
Message-ID: <20100615.181301.241436588.davem@davemloft.net>
References: <1276506144.2478.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753683Ab0FPBMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 21:12:49 -0400
In-Reply-To: <1276506144.2478.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Jun 2010 11:02:24 +0200

> Instead of doing one atomic operation per frag, we can factorize them.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

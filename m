From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] myri10ge: fix the invokation of lro_flush_all
Date: Mon, 25 May 2009 00:36:33 -0700 (PDT)
Message-ID: <20090525.003633.193660737.davem@davemloft.net>
References: <4A19676D.5020606@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42777
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758923AbZEYHgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:36:35 -0400
In-Reply-To: <4A19676D.5020606@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Sun, 24 May 2009 17:27:41 +0200

> Fix the way we check whether lro_flush_all should be called
> in the myri10ge driver.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied to net-next-2.6

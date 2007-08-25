From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/30] net: Avoid pointless allocation casts in BSD
 compression module
Date: Fri, 24 Aug 2007 23:25:01 -0700 (PDT)
Message-ID: <20070824.232501.08140344.davem@davemloft.net>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
	<fd58f69b12c07872b351261199f3c677c6786f06.1187912217.git.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jesper.juhl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43923
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754646AbXHYGZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:25:02 -0400
In-Reply-To: <fd58f69b12c07872b351261199f3c677c6786f06.1187912217.git.jesper.juhl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Fri, 24 Aug 2007 02:06:58 +0200

> The general kernel memory allocation functions return void pointers
> and there is no need to cast their return values.
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

Applied.

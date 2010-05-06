From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Use 'bool' for netpoll_rx() return type.
Date: Thu, 06 May 2010 01:30:48 -0700 (PDT)
Message-ID: <20100506.013048.124061635.davem@davemloft.net>
References: <20100506.012051.149835101.davem@davemloft.net>
	<g2k412e6f7f1005060127g11f7b1e6vddd448178e1ddff9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47161
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751465Ab0EFIal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:30:41 -0400
In-Reply-To: <g2k412e6f7f1005060127g11f7b1e6vddd448178e1ddff9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 6 May 2010 16:27:44 +0800

> bool ret = false.

Thanks for catching that, fixed.

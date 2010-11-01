From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/3] cxgb4vf: remove call to stop TX queues at
 load time.
Date: Mon, 01 Nov 2010 14:10:25 -0700 (PDT)
Message-ID: <20101101.141025.242147678.davem@davemloft.net>
References: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
	<20101101205951.27716.64800.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39666
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754785Ab0KAVKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:10:01 -0400
In-Reply-To: <20101101205951.27716.64800.stgit@speedy5.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 01 Nov 2010 13:59:51 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Stopping TX queues at driver load time is not necessary.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]gianfar: gfar_remove needs to call unregister_netdev()
Date: Sun, 30 Aug 2009 22:04:43 -0700 (PDT)
Message-ID: <20090830.220443.267796943.davem@davemloft.net>
References: <4A8D559B.3030108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uchiyama.toru@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750929AbZHaFE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:04:29 -0400
In-Reply-To: <4A8D559B.3030108@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toru UCHIYAMA <uchiyama.toru@jp.fujitsu.com>
Date: Thu, 20 Aug 2009 22:54:35 +0900

> This patch solves the problem that the Oops(BUG_ON) occurs by rmmod.
 ...
> Signed-off-by: uchiyama.toru@jp.fujitsu.com

Applied, thank you.

In the future, please list your name as well as your email
address in the Signed-off-by: specification.

Thank you.

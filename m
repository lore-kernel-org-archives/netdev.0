From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wd: fix memory leak
Date: Wed, 14 Jul 2010 17:53:28 -0700 (PDT)
Message-ID: <20100714.175328.71103110.davem@davemloft.net>
References: <1279020192-9484-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, joe@perches.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38977
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757006Ab0GOAxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 20:53:13 -0400
In-Reply-To: <1279020192-9484-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Tue, 13 Jul 2010 15:23:12 +0400

> Unmap mapped IO in wd_probe1() if register_netdev() failed.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/3] ipw2x00: remove old compat_net_dev_ops code
Date: Thu, 16 Apr 2009 02:24:19 -0700 (PDT)
Message-ID: <20090416.022419.247109612.davem@davemloft.net>
References: <1239818309-14899-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752600AbZDPJY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:24:27 -0400
In-Reply-To: <1239818309-14899-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Wed, 15 Apr 2009 21:58:27 +0400

> Since both ipw2100 and ipw2200 are already converted to new
> net_device_ops this code is useless.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied.

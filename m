From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in
 he_init_group()
Date: Tue, 22 Sep 2009 14:25:32 -0700 (PDT)
Message-ID: <20090922.142532.24854998.davem@davemloft.net>
References: <4AB51FE7.7030509@gmail.com>
	<1253384847.2638.4.camel@Joe-Laptop.home>
	<4AB66240.6060703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370AbZIVVZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:25:13 -0400
In-Reply-To: <4AB66240.6060703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 20 Sep 2009 19:11:28 +0200

> he_dev->rbps_virt or he_dev->rbpl_virt allocation may fail, s
> them. Make sure that he_init_group() cleans up after errors.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.

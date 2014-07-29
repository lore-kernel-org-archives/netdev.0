From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: mvpp2: implement ioctl() operation for PHY
 ioctls
Date: Tue, 29 Jul 2014 16:48:11 -0700 (PDT)
Message-ID: <20140729.164811.301176869068457588.davem@davemloft.net>
References: <1406496096-11039-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1406496096-11039-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tawfik@marvell.com, nadavh@marvell.com,
	alior@marvell.com, jason@lakedaemon.net, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com,
	linux-arm-kernel@lists.infradead.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506AbaG2XsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 19:48:12 -0400
In-Reply-To: <1406496096-11039-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sun, 27 Jul 2014 23:21:36 +0200

> This commit implements the ->ndo_do_ioctl() operation so that the
> PHY-related ioctl() calls can work from userspace, which allows
> applications like mii-tool or mii-diag to do their job.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Applied.

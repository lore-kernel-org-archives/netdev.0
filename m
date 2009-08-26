From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] irda/sa1100_ir: fix broken netdev_ops conversion
Date: Tue, 25 Aug 2009 20:39:55 -0700 (PDT)
Message-ID: <20090825.203955.125407912.davem@davemloft.net>
References: <1251125760-6547-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53312
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756590AbZHZDjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 23:39:42 -0400
In-Reply-To: <1251125760-6547-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Mon, 24 Aug 2009 18:56:00 +0400

> This patch is based on commit d2f3ad4 (pxaficp-ir: remove incorrect
> net_device_ops). Do the same for sa1100_ir.
> Untested.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] irda/au1k_ir: fix broken netdev_ops conversion
Date: Tue, 25 Aug 2009 20:39:50 -0700 (PDT)
Message-ID: <20090825.203950.26330430.davem@davemloft.net>
References: <1251125667-6509-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53308
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756583AbZHZDjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 23:39:37 -0400
In-Reply-To: <1251125667-6509-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Mon, 24 Aug 2009 18:54:27 +0400

> This patch is based on commit d2f3ad4 (pxaficp-ir: remove incorrect
> net_device_ops). Do the same for au1k_ir.
> Untested.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied.

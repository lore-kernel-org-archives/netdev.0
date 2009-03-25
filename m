From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] drivers/net/ax88796.c: take IRQ flags from
 platform_device
Date: Tue, 24 Mar 2009 23:31:28 -0700 (PDT)
Message-ID: <20090324.233128.267694096.davem@davemloft.net>
References: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@simtec.co.uk
To: daniel@caiaq.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752734AbZCYGbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:31:40 -0400
In-Reply-To: <1237738361-10184-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@caiaq.de>
Date: Sun, 22 Mar 2009 17:12:40 +0100

> This patch adds support to the ax88796 ethernet driver to take IRQ flags
> given by the platform_device definition.
> 
> Signed-off-by: Daniel Mack <daniel@caiaq.de>

Applied.

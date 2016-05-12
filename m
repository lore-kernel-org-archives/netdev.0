From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ip6_gre: Fix get_size calculation for gre6 tunnel
Date: Thu, 12 May 2016 16:54:16 -0400 (EDT)
Message-ID: <20160512.165416.349752696770813418.davem@davemloft.net>
References: <1462963712-13781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcELUyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:54:24 -0400
In-Reply-To: <1462963712-13781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 11 May 2016 18:48:31 +0800

> Do not include attribute IFLA_GRE_TOS.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.

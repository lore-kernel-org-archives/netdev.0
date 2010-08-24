From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: fix poll implementation
Date: Mon, 23 Aug 2010 20:29:12 -0700 (PDT)
Message-ID: <20100823.202912.25149735.davem@davemloft.net>
References: <4C722A04.2080100@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, monstr@monstr.eu
To: synmyth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56361
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753457Ab0HXD2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:28:54 -0400
In-Reply-To: <4C722A04.2080100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinglin Luan <synmyth@gmail.com>
Date: Mon, 23 Aug 2010 15:57:56 +0800

> Function qlcnic_intr has pointer to qlcnic_host_sds_ring
> as second parameter not pointer to qlcnic_adapter.
> 
> Signed-off-by: Yinglin Luan <synmyth@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] [PATCH] qeth: change some configurations defaults
Date: Mon, 14 Mar 2011 15:40:00 -0700 (PDT)
Message-ID: <20110314.154000.91326111.davem@davemloft.net>
References: <20110314132053.132019386@de.ibm.com>
	<20110314132127.374926261@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757372Ab1CNWjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:39:22 -0400
In-Reply-To: <20110314132127.374926261@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Mon, 14 Mar 2011 14:20:54 +0100

> This patch turns on RX checksum and GRO by default. To improve
> receiving performance and reduce congestion in case of network
> bursts we also increase the default number of inbound buffers.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied, thanks Frank.

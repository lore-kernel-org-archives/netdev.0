From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/5] be2net: fix netdev stats rx_errors and
 rx_dropped
Date: Thu, 11 Jun 2009 02:50:04 -0700 (PDT)
Message-ID: <20090611.025004.102485827.davem@davemloft.net>
References: <20090610122116.GA16429@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757549AbZFKJuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:50:02 -0400
In-Reply-To: <20090610122116.GA16429@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 10 Jun 2009 17:51:16 +0530

> Fix netdev stat rx_errors to cover length related errors and checksum errors and rx_dropped to the pkts dropped due to lack of buffers
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.

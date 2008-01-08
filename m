From: David Miller <davem@davemloft.net>
Subject: Re: [PACKET]: Fix sparse warnings in af_packet.c
Date: Mon, 07 Jan 2008 22:40:07 -0800 (PST)
Message-ID: <20080107.224007.147209422.davem@davemloft.net>
References: <20080107120108.06453951.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35586
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbYAHGkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:40:08 -0500
In-Reply-To: <20080107120108.06453951.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 7 Jan 2008 12:01:08 +0100

>   CHECK   net/packet/af_packet.c
> net/packet/af_packet.c:1876:14: warning: context imbalance in 'packet_seq_start' - wrong count at exit
> net/packet/af_packet.c:1888:13: warning: context imbalance in 'packet_seq_stop' - unexpected unlock
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.

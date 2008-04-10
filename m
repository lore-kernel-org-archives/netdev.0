From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Thu, 10 Apr 2008 04:00:56 -0700 (PDT)
Message-ID: <20080410.040056.130569073.davem@davemloft.net>
References: <20080401130842.579e0ebc@extreme>
	<20080410.015118.103465510.davem@davemloft.net>
	<47FDDD61.9020709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49333
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754497AbYDJLAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 07:00:55 -0400
In-Reply-To: <47FDDD61.9020709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 10 Apr 2008 11:26:57 +0200

> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.26, thanks everyone.

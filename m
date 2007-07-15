From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make
 net/ipv4/inet_timewait_sock.c:__inet_twsk_kill() static
Date: Sat, 14 Jul 2007 19:01:13 -0700 (PDT)
Message-ID: <20070714.190113.58787016.davem@davemloft.net>
References: <20070712235556.GU3492@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757550AbXGOCBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 22:01:11 -0400
In-Reply-To: <20070712235556.GU3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 13 Jul 2007 01:55:56 +0200

> This patch makes the needlessly global __inet_twsk_kill() static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.

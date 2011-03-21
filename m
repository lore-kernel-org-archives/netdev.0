From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] socket: increase default maximum listen queue
 length
Date: Sun, 20 Mar 2011 17:18:16 -0700 (PDT)
Message-ID: <20110320.171816.183049702.davem@davemloft.net>
References: <1300662282-24741-1-git-send-email-hagen@jauu.net>
	<20110320.160906.112595807.davem@davemloft.net>
	<20110320235253.GD3038@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44269
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751832Ab1CUARi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 20:17:38 -0400
In-Reply-To: <20110320235253.GD3038@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Mon, 21 Mar 2011 00:52:53 +0100

> The number is somewhat magically - like many other values. I greped
> tglx/history.git but the comment (at that time tcp_ipv4.c) seems pre 2002 era.

Then don't use that number as part of the justification for the
change.

Describe what matters, and only what matters.  Providing magic and
arbitrary numbers doesn't help people reading your commit message.

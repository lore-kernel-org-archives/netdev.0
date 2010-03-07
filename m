From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sock.c: potential null dereference
Date: Sun, 07 Mar 2010 15:28:10 -0800 (PST)
Message-ID: <20100307.152810.247228037.davem@davemloft.net>
References: <20100306110445.GC4958@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jengelh@medozas.de,
	mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50941
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751421Ab0CGX1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:27:50 -0500
In-Reply-To: <20100306110445.GC4958@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 6 Mar 2010 14:04:45 +0300

> We test that "prot->rsk_prot" is non-null right before we dereference it
> on this line.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.

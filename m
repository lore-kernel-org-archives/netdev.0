From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: add missing parentheses
Date: Thu, 16 Jul 2009 18:08:35 -0700 (PDT)
Message-ID: <20090716.180835.13703979.davem@davemloft.net>
References: <4A5A5852.4010901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, atl1-devel@lists.sourceforge.net,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933444AbZGQBIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:08:30 -0400
In-Reply-To: <4A5A5852.4010901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 12 Jul 2009 23:40:34 +0200

> Parentheses are required or the comparison occurs before the bitand.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

I'm sick and tired of waiting for someone to test this and it's so
damn obvious, so, applied.  Thanks!

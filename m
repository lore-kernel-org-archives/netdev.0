From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: add missing parentheses
Date: Sun, 12 Jul 2009 14:40:42 -0700 (PDT)
Message-ID: <20090712.144042.64904532.davem@davemloft.net>
References: <4A5A5852.4010901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, atl1-devel@lists.sourceforge.net,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60409
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750739AbZGLVki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 17:40:38 -0400
In-Reply-To: <4A5A5852.4010901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 12 Jul 2009 23:40:34 +0200

> Parentheses are required or the comparison occurs before the bitand.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Scary... can someone test this before I apply it please?

Thanks.

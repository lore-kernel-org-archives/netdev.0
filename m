From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: Read buffer overflow
Date: Sun, 02 Aug 2009 12:31:04 -0700 (PDT)
Message-ID: <20090802.123104.86253382.davem@davemloft.net>
References: <4A72F51F.3000503@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49070
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753462AbZHBTaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:30:55 -0400
In-Reply-To: <4A72F51F.3000503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 31 Jul 2009 15:43:59 +0200

> Check whether index is within bounds before testing the element.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sun3: print when lance_open() fails
Date: Thu, 12 Feb 2009 16:40:26 -0800 (PST)
Message-ID: <20090212.164026.216860195.davem@davemloft.net>
References: <4992EB41.1030405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sammy@sammy.net, netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758995AbZBMAkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:40:32 -0500
In-Reply-To: <4992EB41.1030405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 11 Feb 2009 16:14:09 +0100

> With while (--i > 0) { ... } i reaches 0; print when lance_open() fails
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.

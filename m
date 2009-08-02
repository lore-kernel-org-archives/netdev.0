From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: Read buffer overflow
Date: Sun, 02 Aug 2009 12:31:41 -0700 (PDT)
Message-ID: <20090802.123141.91834055.davem@davemloft.net>
References: <4A7531AC.4090400@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49080
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753416AbZHBTbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:31:33 -0400
In-Reply-To: <4A7531AC.4090400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 02 Aug 2009 08:26:52 +0200

> Check whether index is within bounds before testing the element.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tty: Flags should be accessed via the foo_bit
 interfaces
Date: Fri, 05 Dec 2008 22:32:01 -0800 (PST)
Message-ID: <20081205.223201.125918780.davem@davemloft.net>
References: <20081205170826.3474.38297.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51487
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751327AbYLFGcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2008 01:32:00 -0500
In-Reply-To: <20081205170826.3474.38297.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 05 Dec 2008 17:08:27 +0000

> From: Alan Cox <alan@redhat.com>
> 
> We have various drivers that poke around directly and we need to clean this
> up before it causes problems.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>

Applied to net-next-2.6

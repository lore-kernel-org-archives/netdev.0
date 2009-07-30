From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] docbook: fix printk of ip address
Date: Thu, 30 Jul 2009 13:10:58 -0700 (PDT)
Message-ID: <20090730.131058.151739419.davem@davemloft.net>
References: <20090730122518.995a83ba.randy.dunlap@oracle.com>
	<20090730.123151.191002348.davem@davemloft.net>
	<20090730123746.1fe58340.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tklauser@distanz.ch
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40861
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752572AbZG3UKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:10:50 -0400
In-Reply-To: <20090730123746.1fe58340.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 30 Jul 2009 12:37:46 -0700

> From: Tobias Klauser <tklauser@distanz.ch>
> 
> Use the %pI4 format string instead of %d.%d.%d.%d and NIPQUAD.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks.

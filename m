From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Delete isa-skeleton net driver
Date: Fri, 26 Feb 2010 12:49:33 -0800 (PST)
Message-ID: <20100226.124933.210312577.davem@davemloft.net>
References: <20100226202048.GA908@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966107Ab0BZUtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 15:49:15 -0500
In-Reply-To: <20100226202048.GA908@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 26 Feb 2010 15:20:48 -0500

> 
> The ISA skeleton net driver has been obsolete and unmaintained for many
> years.  Any hardware remotely like ISA will use the platform API and
> look much more like a PCI driver, and make much better use of netdev
> APIs such as NAPI.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

Fair enough, applied.

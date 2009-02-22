From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] llc: fix non-const printk warning
Date: Sun, 22 Feb 2009 00:02:50 -0800 (PST)
Message-ID: <20090222.000250.32125748.davem@davemloft.net>
References: <20090220100206.533d59d4@extreme>
	<20090220213722.GB18285@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47252
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752428AbZBVIDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:03:08 -0500
In-Reply-To: <20090220213722.GB18285@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 20 Feb 2009 18:37:22 -0300

> Em Fri, Feb 20, 2009 at 10:02:06AM -0800, Stephen Hemminger escreveu:
> > Mark some strings as const.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Thanks,
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.

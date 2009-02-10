From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] enic: record all bad FCS errs as frame
 errors
Date: Mon, 09 Feb 2009 23:26:38 -0800 (PST)
Message-ID: <20090209.232638.41763353.davem@davemloft.net>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
	<20090210005717.24315.53750.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54067
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750887AbZBJH0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 02:26:44 -0500
In-Reply-To: <20090210005717.24315.53750.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 09 Feb 2009 16:57:17 -0800

> enic: record all bad FCS errs as frame errors
>
> Report all bad FCS errs as frames errs.  This includes frames with
> bad FCS on wire detected by MAC and frames which may be truncated
> due to ingress FIFO overruns.  No longer print a driver msg on bad
> FCS err.
>
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.

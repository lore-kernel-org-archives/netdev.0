From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: probably bug in drr scheduler, 2.6.29-rc5
Date: Fri, 27 Feb 2009 05:18:48 -0800 (PST)
Message-ID: <20090227.051848.75275896.davem@davemloft.net>
References: <20090227110137.GF4156@ff.dom.local>
	<20090227.031620.155361122.davem@davemloft.net>
	<20090227112500.GG4156@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org, kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47947
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752153AbZB0NTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 08:19:08 -0500
In-Reply-To: <20090227112500.GG4156@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 27 Feb 2009 11:25:00 +0000

> On Fri, Feb 27, 2009 at 03:16:20AM -0800, David Miller wrote:
> ...
> > This bug doesn't exist in earlier releases like 2.6.28 and 2.6.27?
> 
> Yes, sch_drr is 2.6.29 born.

Perfect, nothing to queue up for -stable then :-)

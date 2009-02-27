From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: probably bug in drr scheduler, 2.6.29-rc5
Date: Fri, 27 Feb 2009 11:25:00 +0000
Message-ID: <20090227112500.GG4156@ff.dom.local>
References: <20090227101634.GD4156@ff.dom.local> <20090227.024613.141114390.davem@davemloft.net> <20090227110137.GF4156@ff.dom.local> <20090227.031620.155361122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:60631 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbZB0LZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 06:25:07 -0500
Received: by bwz26 with SMTP id 26so974338bwz.37
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 03:25:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090227.031620.155361122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 03:16:20AM -0800, David Miller wrote:
...
> This bug doesn't exist in earlier releases like 2.6.28 and 2.6.27?

Yes, sch_drr is 2.6.29 born.

Jarek P.

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: e1000e-1.1.2 Compile errors with 2.4.37 and gcc 2.95.3
Date: Tue, 09 Feb 2010 11:21:49 +0000
Message-ID: <1265714509.2671.134.camel@localhost>
References: <20100209095803.236980@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Marco Schwarz <marco.schwarz@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41705 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab0BILV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:21:57 -0500
In-Reply-To: <20100209095803.236980@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-09 at 10:58 +0100, Marco Schwarz wrote:
> Hi,
> 
> I get the following output when trying to compile e1000e-1.1.2 with Linux Kernel 2.4.37 and gcc 2.95.3 (e1000-8.0.16 compiles fine):
[...]

netdev only deals with recent 2.6 kernels.  I'm amazed that Intel still
wastes time on 2.4.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] tulip: Read buffer overflow
Date: Sun, 2 Aug 2009 15:45:13 -0400
Message-ID: <20090802194513.GD28572@bombadil.infradead.org>
References: <4A7531AC.4090400@gmail.com> <20090802.123141.91834055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roel.kluin@gmail.com, grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37127 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbZHBTpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:45:15 -0400
Content-Disposition: inline
In-Reply-To: <20090802.123141.91834055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 02, 2009 at 12:31:41PM -0700, David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Sun, 02 Aug 2009 08:26:52 +0200
> 
> > Check whether index is within bounds before testing the element.
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Applied.
> 

Thanks Dave, Roel.

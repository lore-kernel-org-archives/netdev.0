From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought up
Date: Thu, 25 Jan 2007 15:12:17 -0500
Message-ID: <20070125201217.GF10282@tuxdriver.com>
References: <1169707854.10593.41.camel@dv> <200701251151.32019.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3230 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030559AbXAYUi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 15:38:29 -0500
Content-Disposition: inline
In-Reply-To: <200701251151.32019.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 25, 2007 at 11:51:27AM -0500, Michael Wu wrote:
> On Thursday 25 January 2007 01:50, Pavel Roskin wrote:
> > If the hardware drivers are supposed to do it, here's my patch.  It is
> > working fine for me and ready to be applied.  The changelog is in the
> > subject.
> Let's fix this in the stack. This problem will be fixed for most users once 
> auto channel selection is implemented, and fixing it for users manually 
> setting the channel should be trivial.

ACK...fixing the stack makes the most sense.

-- 
John W. Linville
linville@tuxdriver.com

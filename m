From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: net-2.6.24 rebased...
Date: Wed, 26 Sep 2007 08:46:49 -0400
Message-ID: <20070926124649.GC6171@tuxdriver.com>
References: <20070925.233344.43202361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2725 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598AbXIZNIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 09:08:09 -0400
Content-Disposition: inline
In-Reply-To: <20070925.233344.43202361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 25, 2007 at 11:33:44PM -0700, David Miller wrote:

> John, one patch didn't go in cleanly after I removed the
> Z1211 driver.  I put it here for your consideration so it
> doesn't get lost:
> 
> 	http://vger.kernel.org/~davem/0433-Z1211-Fix-TX-status-reports.patch
> 
> What probably needs to happen is some other changes that
> were in z1211 need to go into the non-mac80211 driver and
> then this patch applies correctly.

I have that one, so we're fine.  It is a mac80211-specific fix,
so I think that takes care of it.

Thanks!

John
-- 
John W. Linville
linville@tuxdriver.com

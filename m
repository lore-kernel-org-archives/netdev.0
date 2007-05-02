From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] libertas: fix for wireless Kconfig changes
Date: Wed, 2 May 2007 09:36:51 -0400
Message-ID: <20070502133651.GB6187@tuxdriver.com>
References: <20070429002844.GA11225@tuxdriver.com> <1178020418.21671.3.camel@localhost.localdomain> <20070501135454.GD8604@tuxdriver.com> <1178107855.31220.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4513 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993170AbXEBNwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 09:52:18 -0400
Content-Disposition: inline
In-Reply-To: <1178107855.31220.21.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2007 at 08:10:55AM -0400, Dan Williams wrote:
> On Tue, 2007-05-01 at 09:54 -0400, John W. Linville wrote:
> > On Tue, May 01, 2007 at 07:53:38AM -0400, Dan Williams wrote:

> > > Will apply, we need to pull in wireless-dev first to get the NET_RADIO
> > > name change.
> > 
> > No, that is already in Linus' tree via Jeff's tree.
> > 
> > Jeff, I figured you would just apply the patch.  If you'd prefer I
> > can send a pull request, but I don't have anything else pending ATM.
> 
> Really?  Marcelo said he pulled 2.6.21 into the libertas tree but that
> didn't appear to touch drivers/net/wireless/Kconfig at all...

The changes are after 2.6.21.

John
-- 
John W. Linville
linville@tuxdriver.com

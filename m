From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'libertas-fixes' branch of wireless-2.6
Date: Tue, 12 Jun 2007 20:03:12 -0400
Message-ID: <20070613000312.GB4187@tuxdriver.com>
References: <20070529183347.GD3496@tuxdriver.com> <20070612210544.GF310@tuxdriver.com> <20070612210658.GG310@tuxdriver.com> <466F242B.1030900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4380 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbXFMAYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 20:24:46 -0400
Content-Disposition: inline
In-Reply-To: <466F242B.1030900@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 06:54:35PM -0400, Jeff Garzik wrote:
> John W. Linville wrote:
> >Fixes identified by the libertas team as important for 2.6.22...
> >
> >---
> >
> >The following changes since commit 
> >717c9339202a42ae7bec7d3c4b84deecdcae9f81:
> >  Dan Williams (1):
> >        libertas: reduce SSID and BSSID mixed-case abuse
> >
> >are found in the git repository at:
> >
> >  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git 
> >  libertas-fixes
> >
> >Dan Williams (1):
> >      libertas: actually send mesh frames to mesh netdev
> >
> >Luis Carlos (1):
> >      libertas: convert libertas_mpp into anycast_mask
> >
> >Luis Carlos Cobo Rus (2):
> >      libertas: pull current channel from firmware on mesh autostart
> >      libertas: deauthenticate from AP in channel switch
> 
> Just to be clear, you intend 'libertas' and 'libertas-fixes' (in that 
> order) for 2.6.22, and 'libertas-upstream' for 2.6.23?

Yes, correct.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com

From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: 2.6.19-rc5-mm2 -- bcm43xx busted (backing out the bcm43xx patches fixes it)
Date: Wed, 15 Nov 2006 21:26:29 -0500
Message-ID: <20061116022624.GC3439@tuxdriver.com>
References: <a44ae5cd0611141521pd342109jaae9e27aca3d2200@mail.gmail.com> <200611152116.30734.rjw@sisk.pl> <455BCA05.8000007@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Miles Lane <miles.lane@gmail.com>,
	Andrew Morton <akpm@osdl.org>, Bcm43xx-dev@lists.berlios.de,
	Michael Buesch <mb@bu3sch.de>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:34576 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1162224AbWKPCb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 21:31:27 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <455BCA05.8000007@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 15, 2006 at 08:16:37PM -0600, Larry Finger wrote:

> NOTE to maintainers: This problem affects BOTH wireless-2.6 and 
> 2.6.19-rcX-mmY. At present, the
> "Move IV/ICV" patch has not been incorporated into 2.6.19-rcX and it is OK.

This patch is available in the 'upstream' branch pull request I posted
yesterday evening:

	http://marc.theaimsgroup.com/?l=linux-netdev&m=116355611923558&w=2

Hth!

John
-- 
John W. Linville
linville@tuxdriver.com

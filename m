From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] ieee80211softmac: Fix errors related to the work_struct changes
Date: Mon, 11 Dec 2006 16:49:04 -0500
Message-ID: <20061211214858.GA3415@tuxdriver.com>
References: <20061210173908.GB29871@p15091797.pureserver.info> <457CDD7B.8080207@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3236 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763154AbWLKWMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 17:12:25 -0500
To: Larry Finger <larry.finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <457CDD7B.8080207@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 10, 2006 at 10:24:27PM -0600, Larry Finger wrote:

> I thought that when someone _BROKE_ an interface with this kind of change, 
> it was their duty to fix _ALL_ parts of the system that uses this facility. 
> At a minimum, shouldn't all maintainers get a heads up? I don't subscribe 
> to LKML, but I peruse the summary and I certainly do not recall seeing a 
> warning that this change was coming.

FWIW, there was some coverage on LWN.

-- 
John W. Linville
linville@tuxdriver.com

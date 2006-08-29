From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Tue, 29 Aug 2006 07:49:22 -0400
Message-ID: <20060829114915.GB29669@tuxdriver.com>
References: <44F3572E.8020506@linux.intel.com> <1156837757.3788.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:52228 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964955AbWH2LuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 07:50:18 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156837757.3788.10.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 09:49:17AM +0200, Johannes Berg wrote:
> I intend to kill the nick command with nl80211 since it seems to be
> useless. Any objections?

I can't defend it myself, but I have heard of people using it.
I think some of the distro's init scripts might set it as well?

Can anyone defend the practice of setting a nickname for a wireless
device?

John
-- 
John W. Linville
linville@tuxdriver.com

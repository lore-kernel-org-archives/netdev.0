From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] cfg80211/nl80211 core
Date: Mon, 25 Sep 2006 11:05:07 +0200
Message-ID: <1159175107.4509.15.camel@ux156>
References: <1158230812.2936.46.camel@ux156>
	 <1158230963.2936.49.camel@ux156> <20060922174811.6485d795@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4296 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750804AbWIYJEV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 05:04:21 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060922174811.6485d795@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-22 at 17:48 +0200, Jiri Benc wrote:
> On Thu, 14 Sep 2006 12:49:23 +0200, Johannes Berg wrote:
> > There should be support for notifications, but we need to figure
> > out if we remove the sysfs based add/remove virtual interface
> > thing completely or allow the driver to create a notification
> > through some new API here.
> 
> Feel free to remove it if it makes your work easier.

It definitely would.

johannes

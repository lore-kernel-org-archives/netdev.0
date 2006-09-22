From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC 1/3] cfg80211/nl80211 core
Date: Fri, 22 Sep 2006 17:48:11 +0200
Message-ID: <20060922174811.6485d795@logostar.upir.cz>
References: <1158230812.2936.46.camel@ux156>
	<1158230963.2936.49.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:38299 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964771AbWIVPsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 11:48:14 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1158230963.2936.49.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 12:49:23 +0200, Johannes Berg wrote:
> There should be support for notifications, but we need to figure
> out if we remove the sysfs based add/remove virtual interface
> thing completely or allow the driver to create a notification
> through some new API here.

Feel free to remove it if it makes your work easier.

 Jiri

-- 
Jiri Benc
SUSE Labs

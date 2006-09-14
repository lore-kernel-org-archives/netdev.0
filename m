From: Dan Williams <dcbw@redhat.com>
Subject: Re: more nl80211 stuff
Date: Thu, 14 Sep 2006 09:41:29 -0400
Message-ID: <1158241289.2634.7.camel@localhost.localdomain>
References: <1158230812.2936.46.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40121 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750762AbWINNrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 09:47:17 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1158230812.2936.46.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-14 at 12:46 +0200, Johannes Berg wrote:
> Hi,
> 
> Last night I thought a bit more about configuration handling with
> cfg80211/nl80211 and have refined the original framework to be more
> split into cfg80211 and nl80211 stuff.

Can you describe a bit more what the scope of each of nl80211 and
cfg80211 is?  Not sure I entirely understand the split and where the
line is drawn.

Thanks,
Dan

> As a followup, I'll post three patches, the first two are essentially
> the original ones respun, while the third one represents my current
> thoughts (a bit less I guess) on actual configuration and WE
> compatibility.
> 
> johannes
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


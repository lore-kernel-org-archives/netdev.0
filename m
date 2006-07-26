From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style
 names
Date: Wed, 26 Jul 2006 18:53:33 +0200
Message-ID: <20060726185333.36e13fdd@griffin.suse.cz>
References: <200607242302.58670.flamingice@sourmilk.net>
	<20060726183200.79fb431e@griffin.suse.cz>
	<200607260944.01692.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:18818 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030207AbWGZQxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 12:53:35 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607260944.01692.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Jul 2006 09:43:55 -0700, Michael Wu wrote:
> I still want to convert d80211_mgmt.h. Once that's done, I'll look through for 
> those tabs/spaces & long lines formatting issues. I won't mind if you start 
> fixing some of those issues now, however. :)

I just meant running some s/ {8}/\t/ on your patch :-)

Also, I don't want to fix all of tab issues in d80211 by one big patch.
I always have several patches pending (and other people probably too)
and it leads to unnecessary rejects when applying them. Instead, I
gradually correct them when changing corresponding lines.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

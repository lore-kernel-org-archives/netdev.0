From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Fri, 03 Nov 2006 10:21:01 +0100
Message-ID: <1162545661.2923.24.camel@ux156>
References: <20061102223854.692274000@sipsolutions.net> >
	 <20061102230013.960383000@sipsolutions.net> >
	 <1162513367.3381.11.camel@johannes.berg>
	 <1162514791.3381.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37514 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752699AbWKCJT6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 04:19:58 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <1162514791.3381.14.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-03 at 01:46 +0100, Johannes Berg wrote:

> d80211-reduce-mdev.patch
> d80211-ethtool.patch
> d80211-cookie.patch

GRRRR, whitespace damaged. I swear I'm going to submit a s/ {8}/\t/
patch some of these days. wiggle should handle that just fine, and
personally, I have reached a point where I'm far more annoyed by the
damaged whitespace all over than I would be if a patch failed to apply
(which actually happens all the time, so it's sort of a regular thing)

In the meantime, I've fixed the damage.

johannes

From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New stuff in wireless-dev, wireless developers please pull...
Date: Fri, 03 Nov 2006 10:07:52 +0100
Message-ID: <1162544872.2923.18.camel@ux156>
References: <20061103043024.GF2989@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51850 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752705AbWKCJGw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 04:06:52 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061103043024.GF2989@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 23:30 -0500, John W. Linville wrote:

> I've also added a 'pending' branch, with similar policies to the
> 'pending' branch in wireless-2.6 (i.e it means I've got the patch,
> but I'm waiting on some feedback or changes, etc).

Note that the d80211: change the cookie to be opaque as committed is
actually slightly buggy as I pointed out in a follow-up mail, the quilt
dir that's up on my homepage (which is now accessible too...) contains
the fixed version.

> One big addition is the cfg80211/nl80211 stuff from Johannes.  I'm not
> quite confident that the Kconfig stuff is right, but the code is there.

Nice :)

johannes

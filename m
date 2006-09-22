From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: use list_for_each_entry{,_safe}
Date: Fri, 22 Sep 2006 14:00:39 +0200
Message-ID: <20060922140039.7e66cefc@logostar.upir.cz>
References: <1156927420.4013.57.camel@ux156>
	<20060830154322.GA18041@instant802.com>
	<1157007530.3065.0.camel@ux156>
	<20060921194823.1ae45b10@logostar.upir.cz>
	<1158915872.5368.14.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:32390 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932326AbWIVMAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 08:00:41 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1158915872.5368.14.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 11:04:32 +0200, Johannes Berg wrote:
> This patch changes (hopefully!) all occurrences in d80211 of
> list_for_each to list_for_each_entry (and _safe variants where they were
> used before).

Applied to my tree, thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs

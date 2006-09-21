From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: use list_for_each_entry{,_safe}
Date: Thu, 21 Sep 2006 19:48:23 +0200
Message-ID: <20060921194823.1ae45b10@logostar.upir.cz>
References: <1156927420.4013.57.camel@ux156>
	<20060830154322.GA18041@instant802.com>
	<1157007530.3065.0.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:1964 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751319AbWIURs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 13:48:27 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1157007530.3065.0.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 31 Aug 2006 08:58:50 +0200, Johannes Berg wrote:
> On Wed, 2006-08-30 at 08:43 -0700, Jouni Malinen wrote:
> > Could you please separate cleanup parts (list_for_each changes) from
> > functional changes (adding locking) to make it easier to review the
> > patch?
> 
> Yeah, I guess I should do that.

I'd like see the two things separated too. I need to take a deeper look
into the locking and this would help me a lot.

And please, put the conversion patch as the first one as there will be most
likely no discussion about it :-)

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

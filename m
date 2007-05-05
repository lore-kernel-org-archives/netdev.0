From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] add mac80211 wireless infrastructure
Date: Fri, 04 May 2007 22:57:21 -0700 (PDT)
Message-ID: <20070504.225721.42774143.davem@davemloft.net>
References: <20070505031749.GA5308@tuxdriver.com>
	<20070505052635.GB6041@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423125AbXEEF5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 01:57:19 -0400
In-Reply-To: <20070505052635.GB6041@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Sat, 5 May 2007 01:26:35 -0400

> On Fri, May 04, 2007 at 11:17:49PM -0400, John W. Linville wrote:
> 
> > The wireless developers would like this to be considered for merge
> > in time for 2.6.22.  Patches for at least one mac80211-based driver
> > will follow shortly.
> 
> Ooops!  I forgot to add a "From: Jiri Benc..." line to the top of
> the mailed patches.
> 
> Dave, can you add that before applying them?  Or shall I resend?

That's not a problem.

Usually I just assume that the first Signed-off-by is the
author if I don't get a "From: " else i figure it out
by context.

> P.S.  Hmmm...I would have thought that I would have seen the patches
> I sent by now...?  Did the list eat them?  I don't think they were
> that big...?  Let me know if I need to re-send.

Something caused them to be filtered.  Let's see what vger had
to say:

--
Subject: TABOO linux-wireless@vger.kernel.org: global taboo header: m/^Status:/ 
...
Status:	RO
X-Spam-Status: No, score=-4.3 required=3.0 tests=ALL_TRUSTED,AWL,BAYES_00,
	SPF_HELO_PASS,SPF_PASS autolearn=unavailable version=3.1.8-gr1
X-Spam-Checker-Version:	SpamAssassin 3.1.8-gr1 (2007-02-13) on ra.tuxdriver.com
--

Dammit John, get that tuxdriver.com spam filter fixed!
:-)


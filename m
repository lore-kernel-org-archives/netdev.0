From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 10 May 2007 22:23:35 -0400
Message-ID: <1178850215.4074.6.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
	 <1178666902.4055.28.camel@localhost>
	 <1178766140.3045.24.camel@debian.sh.intel.com>
	 <1178800551.4074.34.camel@localhost>
	 <1178848682.3045.82.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:7575 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326AbXEKCXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 22:23:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so737750wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 19:23:39 -0700 (PDT)
In-Reply-To: <1178848682.3045.82.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 09:58 +0800, Zhu Yi wrote:

> 
> Good, we agree on this. 

Good start.

> Now let's solve the problem.
> 

Lets take it slowly, because i think i wasnt getting anywhere with
Peter. See if you make sense of what i am saying maybe we can make
progress.

> When the low priority ring buffer is full in the hardware, will you
> suppose the driver call netif_stop_queue() or not? 

Yes, I will. 
With a note: This is precisely what i have been saying all along
in my posting. I explained my reasoning; if you missed the why I think i
should write it up.
So in order to make progress - i am going to not respond to the rest of
the email; tell me if you dont understand me and i will do a write up
hopefully tommorow or over the weekend.
Or tell me you understand me and disagree because of ....

cheers,
jamal


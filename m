From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [PATCH 0/7] dccp: add support for dynamic
 parameter updates
Date: Mon, 1 Aug 2011 08:43:37 -0600
Message-ID: <20110801144337.GA4955@gerrit.erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2011-07-25>
 <1311600996-6712-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <20110801.001042.6263177526030880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61017 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750862Ab1HAPDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 11:03:09 -0400
Content-Disposition: inline
In-Reply-To: <20110801.001042.6263177526030880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David S. Miller:
| From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| Date: Mon, 25 Jul 2011 07:36:29 -0600
| 
| > I have also placed this in into a fresh (today's) copy of net-next-2.6, on
| > 
| >     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
| 
| I did a test pull and this URL doesn't work:
| 
| 
Sorry, I must have clobbered something during a subsequent update last week. 

I have just regenerated the whole tree from scratch, including the 'dccp' sub-branch,
using  today's net-next-2.6, double-checking it running 
  git ls-remote git://eden-feed.erg.abdn.ac.uk/net-next-2.6  dccp
and doing a test-pull of the dccp sub-tree.


Can you please consider pulling again, from

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6		[sub-tree 'dccp']


The patch listing of this set is at
  http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git;a=log;h=dccp


Thank you for the update
Gerrit
-- 

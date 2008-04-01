From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [Patch 0/7]: Bug-Fixes and Clean-Ups
Date: Tue, 1 Apr 2008 10:52:15 +0100
Message-ID: <20080401095215.GA27232@gerrit.erg.abdn.ac.uk>
References: <1206462011-24907-1-git-send-email-gerrit@erg.abdn.ac.uk> <5bc4c4570803261744n3a557476qed3b8f52a2ce1def@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Angelo Perkusich <perkusic@dee.ufcg.edu.br>,
	Walter Guerra <waltinhu@gmail.com>
To: Leandro Sales <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35981 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756242AbYDAJwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 05:52:25 -0400
Content-Disposition: inline
In-Reply-To: <5bc4c4570803261744n3a557476qed3b8f52a2ce1def@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >  If no one shouts, I will put that into the tree approximately by the end of
| >  the week. In any case it would be good to know if the CCID-4 tree is still
| >  active, since porting these changes will take quite a bit of work.
| 
| Yes, CCID-4 is still active. I'm very busy finishing many datails for
| my dissertation, this includes writing the document, finishing some
| DCCP for GStreamer fixes, and so on. I plan to back to CCID-4
| implementation in the end of April, beginning of May.
| 
Updated git://eden-feed.erg.abdn.ac.uk/dccp_exp [ccid4] subtree to track
the recent changes in CCID-3. There are two patches in there, one mirrors
the prefix change, the other aggregates all recent bug fixes and changes
made to CCID-3.

This is a bit work-intensive since there are many small patches, while the
actual CCID-4 code is a smaller part of that. It would be good to fold the 
many patches into fewer ones soon. Most of the patches also don't compile 
standalone (only as set), I have done some work on re-ordering chunks to
fix this, but also have other work to do.


The University of Aberdeen is a charity registered in Scotland, No SC013683.


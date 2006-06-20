From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] TIPC updates
Date: Tue, 20 Jun 2006 14:28:13 -0700 (PDT)
Message-ID: <20060620.142813.74565140.davem@davemloft.net>
References: <Pine.LNX.4.64.0606201637050.29502@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30105
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751146AbWFTV2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 17:28:03 -0400
To: per.liden@ericsson.com
In-Reply-To: <Pine.LNX.4.64.0606201637050.29502@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Tue, 20 Jun 2006 16:48:54 +0200 (CEST)

> Please pull from:
> 
> 	git://tipc.cslab.ericsson.net/pub/git/tipc.git

Hi Per.

I agree with James, you should post the patches so that people
can review them.

But not all in one posting! :-)

Look at how other contributors submit their work.  They make a set of
postings to the list, one for each patch, and each posting has
a subject that begins with something like "[PATCH 1/N] " where
the "1" increases for each patch and the "N" is the total number
of patches you are submitting for review.

People typically also give an initial "[PATCH 0/N] " posting
where the location of the GIT tree containing the patches lives
and also a general summary of what the upcoming set of patches
do.

There are automated scripts which can take a GIT tree and a given
range of changesets and prebuild the list postings for you.  So
the amount of work you need to do for this is minimal.

For example, "git format-patch" and "git send-email" can help you a
lot here.

Thanks!

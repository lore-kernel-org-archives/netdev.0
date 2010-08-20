From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp test-tree [PATCH 0/3] ccid-2: Congestion Window
	Validation, TCP code sharing
Date: Fri, 20 Aug 2010 07:38:43 +0200
Message-ID: <20100820053843.GD5414@gerrit.erg.abdn.ac.uk>
References: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk> <20100818.232532.98880936.davem@davemloft.net> <20100818.232805.241450746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46603 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751054Ab0HTFiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 01:38:54 -0400
Content-Disposition: inline
In-Reply-To: <20100818.232805.241450746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, 
| Ok, these obviously have dependencies with things in your dccp
| trees that are not upstream yet, my bad :-)
| 
thank you very much for looking through these and apologies for not making it
fully clear that the patches sat somewhere in the middle of the test tree.

We normally cross-post from dccp@vger also to netdev@vger, in the hope that a
few more people do review.

I would like to (slowly, as we have been doing at the begin of this year)
submit patches from the test tree to netdev, to synchronize the development.

Most patches in the test tree have been there for 2..3 years, hence I would
have a good confidence submitting them.

If you are ok with this, I would submit a small bunch of 4..5 per week, which
would allow to keep this going as a background process.

Thanks again
Gerrit

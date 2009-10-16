From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 0/2] Add implementation of CCID4 into the DCCP test tree
Date: Fri, 16 Oct 2009 08:07:18 +0200
Message-ID: <20091016060718.GA7199@gerrit.erg.abdn.ac.uk>
References: <4AD4B89C.6010704@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:49065 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752840AbZJPGIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:08:11 -0400
Content-Disposition: inline
In-Reply-To: <4AD4B89C.6010704@embedded.ufcg.edu.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| These patches add implementation of CCID4 into the DCCP test tree.
Thank you for sending these.

I have taken all three series,
 * 4-part TFRC-SP receiver set,
 * 4-part TFRC-SP sender set,
 * 2-part CCID-4 implementation set,
and replaced the old ccid4 subtree of the DCCP test tree.


You can checkout the whole CCID-4 subtree via
    git://eden-feed.erg.abdn.ac.uk/dccp_exp    => subtree 'ccid4'

and view (or download) the CCID-4 patch series at
    http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=log;h=ccid4

These are all your patches, no edits apart from removing some trailing whitespace.
If you make changes to your patches please send them relative to this tree.

So far I have only verified that they build cleanly, will be back next week after
some more tests.

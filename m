From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 0/5] Adds implementation of TFRC-SP on DCCP test tree
Date: Wed, 9 Sep 2009 22:19:41 +0200
Message-ID: <20090909201941.GB5205@gerrit.erg.abdn.ac.uk>
References: <4AA6A252.5060405@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47061 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752953AbZIIUTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 16:19:51 -0400
Content-Disposition: inline
In-Reply-To: <4AA6A252.5060405@embedded.ufcg.edu.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| These patches adds implementation of TFRC-SP at the receiver side, and
| are targeted at the DCCP branch
<snip> 
| 
| Following this patches, we'll be sending the sender side of TFRC-SP.
| Once this code is integrated on the branch, we can proceed adding the
| CCID4 code that uses this new TFRC-SP.

Thanks for all the work and for resending. I will be going through these
over the weekend. My suggestion is that if they compile and work cleanly,
to replace the existing patches in the CCID-4 subtree, so that testing
of the experimental CCID-4 features can continue.

Thanks a lot
Gerrit

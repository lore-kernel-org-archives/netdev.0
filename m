From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp test-tree [RFC] [Patch 2/2] dccp: CCID2 check ack ratio
	when reducing cwnd
Date: Fri, 18 Mar 2011 12:33:03 +0100
Message-ID: <20110318113303.GB5508@gerrit.erg.abdn.ac.uk>
References: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk> <1299559831.7569.41.camel@jero-laptop> <20110311113042.GB4876@gerrit.erg.abdn.ac.uk> <1300164797.20638.65.camel@jero-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Samuel Jero <sj323707@ohio.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:44957 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752838Ab1CRLdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 07:33:07 -0400
Content-Disposition: inline
In-Reply-To: <1300164797.20638.65.camel@jero-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| This patch causes CCID2 to check the ack ratio after reducing the
| congestion window.
Thanks a lot, it has been integrated with the other changes:
  http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=f7bcfc7ddf5c1f61c861c3d2b475df7874833ed3

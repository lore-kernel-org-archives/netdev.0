From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
	feature-negotiation patches
Date: Tue, 9 Sep 2008 13:59:48 +0200
Message-ID: <20080909115948.GA3551@gerrit.erg.abdn.ac.uk>
References: <20080904061511.GA30756@gerrit.erg.abdn.ac.uk> <20080908.173250.204419507.davem@davemloft.net> <20080909080911.GA9176@gerrit.erg.abdn.ac.uk> <20080909.015720.204027435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43924 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753345AbYIIMCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 08:02:04 -0400
Content-Disposition: inline
In-Reply-To: <20080909.015720.204027435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's keep this clean and simple. There has been a mistake here and it
needs to be fixed. It does not help to argue loudly whose fault it was.

Please consider pulling from

	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	 [subtree `master']
	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git;a=summary

where I have reverted the pull and compile-tested the result. 

We can talk about the rest once you have cooled down.

Gerrit

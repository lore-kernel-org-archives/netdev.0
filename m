From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Date: Mon, 3 Mar 2008 13:57:46 +0000
Message-ID: <20080303135745.GA15241@gerrit.erg.abdn.ac.uk>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk> <20080229142334.GL4306@ghostprotocols.net> <20080303073454.GA6937@gerrit.erg.abdn.ac.uk> <20080303130209.GA4196@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53304 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752772AbYCCN61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 08:58:27 -0500
Content-Disposition: inline
In-Reply-To: <20080303130209.GA4196@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > | > [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
<snip>
| > Are you basically ok with the naming scheme, do you have other
| > suggestions or are there additional considerations?
| 
| Its ok, everywhere we use hctx or hcrx as the variable name, so its ok
| for plain old grep to find it.
| 
Great, thanks for checking this. It makes the code much clearer.

Will check this RFC patch once again and upload it, doing a similar 
update for CCID-3/-4 is further work.

Cheers
Gerrit

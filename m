From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Date: Mon, 3 Mar 2008 07:34:54 +0000
Message-ID: <20080303073454.GA6937@gerrit.erg.abdn.ac.uk>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk> <20080229142334.GL4306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35205 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751180AbYCCHfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 02:35:47 -0500
Content-Disposition: inline
In-Reply-To: <20080229142334.GL4306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
<snip>
| I haven't checked, is this over what is now on the test tree or on
| upstream?
| 
The patch applies on top of the test tree (now online again), i.e. it 
should apply when checking out a separate branch with the test tree in it.

Are you basically ok with the naming scheme, do you have other
suggestions or are there additional considerations?

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: dccp test tree [RFC/RFT] [Patch 1/3] dccp: minor Kconfig
	cosmetics
Date: Tue, 6 Jan 2009 13:22:23 +0100
Message-ID: <20090106122222.GA4448@gerrit.erg.abdn.ac.uk>
References: <20090105144213.GB3773@gerrit.erg.abdn.ac.uk> <4962AE90.3030706@cn.fujitsu.com> <39e6f6c70901051717p33da63b2ra8dade1da945624@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34245 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751823AbZAFMWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 07:22:41 -0500
Content-Disposition: inline
In-Reply-To: <39e6f6c70901051717p33da63b2ra8dade1da945624@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Arnaldo Carvalho de Melo:
| On Mon, Jan 5, 2009 at 11:06 PM, Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
| > Gerrit Renker wrote:
| 
| >> +         value. Values in units of milliseconds can be set here.
| >> +
| >> +         A value of 0 disables this feature by enforcing the value
| >> specified
| >> +         in RFC 5448. The following values have been suggested as bounds
| >> for
| >>
| >
| > RFC 5448 should be RFC 5348.
| 
| Indeed.
| 
A genuine blunder - I had verified the section references but not the
RFC number. It is really good to see that people do look: that is why
I don't make changes to the test tree without also submitting these.

The only exception to this rule are a few patches that have been
deleted, such as the one to auto-load CCIDs, and 2 patches that became
obsolete in the CCID-4 tree. At the moment I don't know what to do
with that CCID-4 tree, will just keep it up-to-date, it might be good to
reorganise the about 20 patches some time.

Again thanks a lot to you, Wei, and Ian
Gerrit

Just fixed it in the test tree
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=11fc1dc11eafab0bd18c22f717a9b2155a383383

From: Greg Lindahl <greg@blekko.com>
Subject: Re: Treason uncloaked / Broken peer again
Date: Tue, 10 Mar 2009 12:37:19 -0700
Message-ID: <20090310193719.GF11157@bx9.net>
References: <20090226085826.GA12498@gondor.apana.org.au> <Pine.LNX.4.64.0902261105030.31742@wrl-59.cs.helsinki.fi> <20090227212234.GB25573@bx9.net> <20090227.163105.240371624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:38926 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbZCJThV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 15:37:21 -0400
Content-Disposition: inline
In-Reply-To: <20090227.163105.240371624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By experimentation we determined that turning off window scaling meant
we didn't trigger "Treason uncloaked" on remote systems.

The recent posting about passive OS fingerprinting led me to

http://www.openbsd.org/cgi-bin/cvsweb/src/etc/pf.os?rev=1.21;content-type=text%2Fplain

which says that Googlebot has window scaling turned off, too.

Things that make me go, "Hmmm."

-- greg



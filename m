From: Andi Kleen <ak@suse.de>
Subject: Re: Firewall question
Date: Fri, 9 Jun 2006 05:43:24 +0200
Message-ID: <200606090543.24401.ak@suse.de>
References: <20060608185712.79340.qmail@web50207.mail.yahoo.com> <20060608192628.GA561@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alex Davis <alex14641@yahoo.com>, netfilter@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40335 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932173AbWFIDq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 23:46:29 -0400
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
In-Reply-To: <20060608192628.GA561@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Well the DSL modem only transfers whatever data the ISP end sends to it,
> which in your case is just PPP packets (LCC or LCP I think).  No one out
> on the internet 

No one out on the internet, but it would be trivial for someone outside
his house. All his traffic will be on a long unsecured cable. 

That is why I would never bridge home ethernet traffic onto a DSL line.

-Andi


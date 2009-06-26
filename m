From: Robert Olsson <robert@robur.slu.se>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 14:42:12 +0200
Message-ID: <19012.49700.908412.410984@robur.slu.se>
References: <4A43E9F1.90209@cosmosbay.com>
	<20090626080302.GB5204@ff.dom.local>
	<19012.37515.146191.198843@robur.slu.se>
	<20090626093727.GA6832@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:35694 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbZFZMmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 08:42:10 -0400
In-Reply-To: <20090626093727.GA6832@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:

 > >  But maybe memory allocation experts has some good suggestions.
 > 
 > Pawel has reported these problems for a long time:
 > http://bugzilla.kernel.org/show_bug.cgi?id=6648
 > 
 > So, until it's fully investigated, it seems some 'fast' fix is needed
 > here.

 We talked about having a fixed pre-allocated root-node long ago but it's only 
 optimisation for routers w. full BGP. Best if memory problems got solved.
 
 Cheers
						--ro

From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 13:49:16 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:61072 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751266AbWDTUtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 16:49:17 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr003.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KKnHS4032691
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:49:17 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KKnH2u015571
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:49:17 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KKnGhF021463
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 13:49:17 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi I'm reposting these, originally posted by Chris Leech a few weeks ago.
However, there is an extra part since I broke up one patch that was too 
big for netdev last time into two (patches 2 and 3).

Of course we're always looking for more style improvement comments, but 
more importantly we're posting these to talk about the larger issues 
around I/OAT and this code making it in upstream at some point.

These are also available on the wiki,  
http://linux-net.osdl.org/index.php/I/OAT .

Thanks -- Andy


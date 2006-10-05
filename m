From: Andi Kleen <ak@suse.de>
Subject: Re: 2.6.18-mm2 boot failure on x86-64 II
Date: Fri, 6 Oct 2006 01:35:56 +0200
Message-ID: <200610060135.56134.ak@suse.de>
References: <20060928014623.ccc9b885.akpm@osdl.org> <200610060114.03466.ak@suse.de> <1160091179.5664.17.camel@keithlap>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: mel gorman <mel@csn.ul.ie>, Vivek goyal <vgoyal@in.ibm.com>,
	Steve Fox <drfickle@us.ibm.com>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Martin Bligh <mbligh@mbligh.org>,
	Andrew Morton <akpm@osdl.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andy Whitcroft <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:28578 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751468AbWJEXii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 19:38:38 -0400
To: kmannth@us.ibm.com
In-Reply-To: <1160091179.5664.17.camel@keithlap>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> As of yet I haven't been able to recreate the hang.  I am running
> similar HW to Steve. 

That was on a 4 core Opteron with Tyan board  (S2881) and AMD-8111 
chipset.

-Andi

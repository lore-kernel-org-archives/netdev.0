From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Thu, 07 Sep 2006 09:45:21 -0700
Message-ID: <1157647521.6411.1.camel@strongmad>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>
	 <44FEE679.6030201@pobox.com>
	 <Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com>
	 <200609061922.k86JMTZt027278@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54921 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1161046AbWIGQpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2006 12:45:25 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609061922.k86JMTZt027278@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Note to self:  Do not use Pine EVER AGAIN.
Sorry for the badness.  Evolution is my new best friend.
-Mitch

On Wed, 2006-09-06 at 12:22 -0700, Jay Vosburgh wrote:
> 
>         [Trying again; /usr/bin/patch didn't complain about Mitch's
> original; here's a cg-diff generated from where I checked his in,
> git-apply seems ok with it.  The problem seems to be the empty line
> between "//endallnoun" and "// compare MAC"; in the original it's a
> totally empty line, from cg-diff, there's a single space on there. -J]

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Wed, 6 Sep 2006 12:23:46 -0700
Message-ID: <20060906122346.1413447f.rdunlap@xenotime.net>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>
	<44FEE679.6030201@pobox.com>
	<Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com>
	<44FEFD16.1040308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:2196 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751505AbWIFTUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 15:20:17 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 12:20:11 -0700
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44FEFD16.1040308@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Sep 2006 12:53:42 -0400 Jeff Garzik wrote:

> Mitch Williams wrote:
> > Add 10 Gig support to bonding.
> > 
> > Resent due to corrupt patch.
> > 
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Acked-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> Did you test with git-applymbox first?
> 
> It's still corrupt...
> 
> 
> Applying 'bonding: Add 10 Gig support'
> 
> fatal: corrupt patch at line 10

The patch applies fine for me (not using that git stuff).
Maybe a tool problem?

---
~Randy

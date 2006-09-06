From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Wed, 06 Sep 2006 10:33:19 -0700
Message-ID: <1157563999.24014.12.camel@dhcp-10-7-81-7.broadcom.com>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>
 <44FEE679.6030201@pobox.com>
 <Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com>
 <44FEFD16.1040308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Mitch Williams" <mitch.a.williams@intel.com>,
	"Jay Vosburgh" <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:38927 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751775AbWIFRea
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 13:34:30 -0400
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <44FEFD16.1040308@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-06 at 12:53 -0400, Jeff Garzik wrote:
> Mitch Williams wrote:
> > Add 10 Gig support to bonding.
> > 
> > Resent due to corrupt patch.
> Did you test with git-applymbox first?
> 
> It's still corrupt...
> 
> 
> Applying 'bonding: Add 10 Gig support'
> 
> fatal: corrupt patch at line 10
> 

I found that if I use git-stripspace on a patch, corruption is reported when using git-applymbox.
If git-stripspace is not used on the patch then git-applymbox will apply the patch with no errors.






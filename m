From: "Mark E Mason" <mark.e.mason@broadcom.com>
Subject: RE: PATCH SB1250 NAPI support
Date: Thu, 29 Jun 2006 10:15:03 -0700
Message-ID: <7E000E7F06B05C49BDBB769ADAF44D07CEB37F@NT-SJCA-0750.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Tom Rix" <trix@specifix.com>,
	"Mark E Mason" <mark.e.mason@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:267 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S1751032AbWF2RPZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 13:15:25 -0400
Content-class: urn:content-classes:message
To: "Martin Michlmayr" <tbm@cyrius.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

We've done some further work on the bcm1250/bcm1480 MAC driver since
then, primarily in the area of performance improvements, but we've not
quite ready to submit the patch for those changes yet.

In the meantime, Tom's patch fixes all of the really bad problems, and
we'd really appreciate it if it could be merged in.

Thx,
Mark Mason
Broadcom

> -----Original Message-----
> From: Martin Michlmayr [mailto:tbm@cyrius.com] 
> Sent: Thursday, June 29, 2006 1:22 AM
> To: jgarzik@pobox.com; netdev@vger.kernel.org
> Cc: Tom Rix; Mark E Mason
> Subject: Re: PATCH SB1250 NAPI support
> 
> * Tom Rix <trix@specifix.com> [2006-06-04 11:45]:
> > A while ago I submitted this patch for NAPI support for 
> SB1250 / SB1480.
> > I have tested it again on the recent (6/3/06) linux-mips kernel.
> 
> Are there any comments regarding this patch (apart from the fact that
> Tom forgot to include a Signed-off-by line).  Can it go in when it's
> resent with a Signed-off-by line or does the patch have any other
> problems?
> -- 
> Martin Michlmayr
> tbm@cyrius.com
> 
> 


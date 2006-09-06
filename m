From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Wed, 06 Sep 2006 16:05:40 -0400
Message-ID: <44FF2A14.9090109@pobox.com>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>	<44FEE679.6030201@pobox.com>	<Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com>	<44FEFD16.1040308@pobox.com> <20060906122346.1413447f.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:64997 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932121AbWIFUFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 16:05:47 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060906122346.1413447f.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> On Wed, 06 Sep 2006 12:53:42 -0400 Jeff Garzik wrote:
> 
>> Mitch Williams wrote:
>>> Add 10 Gig support to bonding.
>>>
>>> Resent due to corrupt patch.
>>>
>>> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
>>> Acked-by: Jay Vosburgh <fubar@us.ibm.com>
>> Did you test with git-applymbox first?
>>
>> It's still corrupt...
>>
>>
>> Applying 'bonding: Add 10 Gig support'
>>
>> fatal: corrupt patch at line 10
> 
> The patch applies fine for me (not using that git stuff).
> Maybe a tool problem?

Linus says git-applymbox is more strict than patch(1).  patch(1) 
intentionally accepts (and attempts to correct) certain types of garbage.

	Jeff




From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/6] 2.6.18: sb1250-mac: Broadcom PHY support
Date: Thu, 05 Oct 2006 07:02:32 -0400
Message-ID: <4524E648.2000706@garzik.org>
References: <Pine.LNX.4.64N.0610031457070.4642@blysk.ds.pg.gda.pl> <4524E5BD.1040000@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58588 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751673AbWJELCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 07:02:37 -0400
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <4524E5BD.1040000@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Maciej W. Rozycki wrote:
>> Hello,
> [...]
>>  Please consider.
>>
>>   Maciej
> 
> 
> Please don't include this in the patch description.  It must be 
> hand-edited out, before applying with git-applymbox.  All comments 
> should be placed AFTER the "---" separator, which terminates the patch 
> description.
> 
> Applied patches 1-3, patch #4 failed due to drivers/net/Kconfig breakage

Also, in your email subject line, the kernel version should be included 
in the [PATCH...] brackets.  Please see 
http://linux.yyz.us/patch-format.html and 
Documentation/SubmittingPatches for more info.

	Jeff



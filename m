From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v3] bnx2x: Alloc 4k fragment for each rx ring buffer
 element
Date: Sun, 17 May 2015 07:14:01 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D9C1DD@avmb3.qlogic.org>
References: <553AD097.4020209@gmx.de>
	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
	<20150430.160537.232956261880122754.davem@davemloft.net>
	<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org>
 <87egmhlggk.fsf@dhcp-9-18-235-171.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"LinoSanfilippo@gmx.de" <LinoSanfilippo@gmx.de>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:31203 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843AbbEQHOO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 03:14:14 -0400
In-Reply-To: <87egmhlggk.fsf@dhcp-9-18-235-171.br.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Regardless, I'll give it a more thorough review tomorrow.
> > [If those are all the "problems" we'll find with it, I don't think
> > we'll need to re-spin this once more; that is, unless Dave insists]
> 
> Hi Yuval,  thanks for your suggestion.
> 
> Just pinging this patch.  Did you have a chance to make another review on this
> one?  Looking forward to see this merged in.
> 
> Thanks!
> 
> --
> Gabriel Krisman Bertazi

Sorry for not responding - I've seen that Dave already moved it into
'changes required' state, so I've assumed you'd shortly send an update.

Reviewed it; Couldn't find anything inherently problematic.

Thanks for the effort.

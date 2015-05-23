From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v4] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Sat, 23 May 2015 13:14:35 +0200
Message-ID: <5560611B.6060500@gmx.de>
References: <553AD097.4020209@gmx.de>	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>	<20150430.160537.232956261880122754.davem@davemloft.net>	<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>	<B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org> <87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:49310 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757551AbbEWLOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2015 07:14:53 -0400
In-Reply-To: <87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.05.2015 15:20, Gabriel Krisman Bertazi wrote:
> Yuval Mintz <Yuval.Mintz@qlogic.com> writes:
> 
>> Regardless, I'll give it a more thorough review tomorrow.
>> [If those are all the "problems" we'll find with it, I don't think we'll
>> need to re-spin this once more; that is, unless Dave insists]
> 
> As a follow up, here is a new version that fixes the style issues that Yuval
> pointed out.  Are there any other concerns regarding this one?
> 

Hi Gabriel,

the patch looks good concerning this issue in a former version:
http://marc.info/?l=linux-netdev&m=142991786419997&w=2

And (at least to me) it also looks good on the whole. You can
add Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>.

Regards,
Lino

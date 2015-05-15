From: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Subject: Re: [PATCH v3] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Fri, 15 May 2015 17:43:23 -0300
Message-ID: <87egmhlggk.fsf@dhcp-9-18-235-171.br.ibm.com>
References: <553AD097.4020209@gmx.de>
	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
	<20150430.160537.232956261880122754.davem@davemloft.net>
	<874mnsxhnm.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	"LinoSanfilippo\@gmx.de" <LinoSanfilippo@gmx.de>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo\@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking\@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:59548 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422661AbbEOUna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 16:43:30 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krisman@linux.vnet.ibm.com>;
	Fri, 15 May 2015 17:43:28 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id BB0A43520068
	for <netdev@vger.kernel.org>; Fri, 15 May 2015 16:42:22 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4FKgF8S5964256
	for <netdev@vger.kernel.org>; Fri, 15 May 2015 17:42:15 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4FKhN2N012683
	for <netdev@vger.kernel.org>; Fri, 15 May 2015 17:43:24 -0300
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63D6F990@AVMB1.qlogic.org> (Yuval
	Mintz's message of "Mon, 4 May 2015 19:58:06 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval Mintz <Yuval.Mintz@qlogic.com> writes:

> Regardless, I'll give it a more thorough review tomorrow.
> [If those are all the "problems" we'll find with it, I don't think we'll
> need to re-spin this once more; that is, unless Dave insists]

Hi Yuval,  thanks for your suggestion.

Just pinging this patch.  Did you have a chance to make another review
on this one?  Looking forward to see this merged in.

Thanks!

-- 
Gabriel Krisman Bertazi

From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [PATCH 1/1] LSM-IPsec SELinux Authorize (with minor fix)
Date: Tue, 6 Jun 2006 10:55:58 -0400
Message-ID: <OF4F545512.79E4862D-ON85257185.005181A7-85257185.00520729@us.ibm.com>
References: <Pine.LNX.4.64.0606060133220.9787@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, davem@davemloft.net, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, latten@austin.ibm.com,
	Serge E Hallyn <sergeh@us.ibm.com>,
	George Wilson <gcwilson@us.ibm.com>, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:15253 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932201AbWFFO4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 10:56:24 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k56Eu1GX019537
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 6 Jun 2006 10:56:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k56Eu18W154570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Jun 2006 10:56:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k56Eu09T026731
	for <netdev@vger.kernel.org>; Tue, 6 Jun 2006 10:56:01 -0400
In-Reply-To: <Pine.LNX.4.64.0606060133220.9787@d.namei>
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Singned-off-by: Catherine Zhang <cxzhang@watson.ibm.com>

James, is this enough or do I need to modify the original patch to add the 
above line?  The code was taken from various pieces of patches originally 
from Trent and merged/modified by me.  Let me know what else I need to do.

thanks,
Catherine

James Morris <jmorris@namei.org> wrote on 06/06/2006 01:37:04 AM:

> On Tue, 6 Jun 2006, Catherine Zhang wrote:
> 
> > Minor fix per James' comment.
> 
> Can you also add a Signed-off-by line?
> 
> I can't recall if you were the original author.   If not, we also need a 

> From line (per Documentation/SubmittingPatches).
> 
> 
> Thanks,
> 
> -- 
> James Morris
> <jmorris@namei.org>


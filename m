From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Thu, 15 May 2014 08:52:27 +0200
Message-ID: <20140515065227.GA10217@osiris>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
 <20140513.183145.1568789082256942703.davem@davemloft.net>
 <20140514080557.GB9848@osiris>
 <20140514.161038.604524051618558919.davem@redhat.com>
 <5373D4BF.1040002@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>, ast@plumgrid.com,
	edumazet@google.com, dborkman@redhat.com, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:40339 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbaEOGwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 02:52:32 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Thu, 15 May 2014 07:52:30 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id C86E0219005E
	for <netdev@vger.kernel.org>; Thu, 15 May 2014 07:52:19 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4F6qSRs196970
	for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:52:28 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4F6qR3f024612
	for <netdev@vger.kernel.org>; Thu, 15 May 2014 00:52:28 -0600
Content-Disposition: inline
In-Reply-To: <5373D4BF.1040002@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 01:40:31PM -0700, H. Peter Anvin wrote:
> On 05/14/2014 01:10 PM, David Miller wrote:
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Date: Wed, 14 May 2014 10:05:57 +0200
> > 
> >> Dave, can you route this via -net?
> > 
> 
> Pardon for being a bit confused, but it would seem x86 or net would be
> the logical routes for this -- I don't mind at all it being routed
> through net, but that would seem to be between myself (and the other x86
> maintainers) and Dave...

Hi Peter,

you missed the s390 version of Alexei's patch which I sent as reply to this
thread. As usual I got a delivery failure for your zytor.com email address
(added your Intel address this time).

So the question was if Dave could add the s390 version of the patch to -net.

Thanks,
Heiko

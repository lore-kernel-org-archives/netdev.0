From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: Re: [PATCH net 1/2] bpf, s390: fix jit branch offset related to
 ldimm64
Date: Fri, 4 Aug 2017 19:10:33 +0200
Message-ID: <20170804191033.30bd8f03@TP-holzheu>
References: <cover.1501848914.git.daniel@iogearbox.net>
        <a63b808ceaa481dfae896bcf611fc489fdc59080.1501848914.git.daniel@iogearbox.net>
        <20170804154420.6faae20a@TP-holzheu>
        <59847C2F.6010306@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59013 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752433AbdHDRKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 13:10:42 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v74H9vYH006444
        for <netdev@vger.kernel.org>; Fri, 4 Aug 2017 13:10:42 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c4t82j0yr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:10:41 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
        Fri, 4 Aug 2017 18:10:39 +0100
In-Reply-To: <59847C2F.6010306@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Fri, 04 Aug 2017 15:52:47 +0200
schrieb Daniel Borkmann <daniel@iogearbox.net>:

> On 08/04/2017 03:44 PM, Michael Holzheu wrote:
> > Am Fri,  4 Aug 2017 14:20:54 +0200
> > schrieb Daniel Borkmann <daniel@iogearbox.net>:
> [...]
> >
> > What about "Cc: stable@vger.kernel.org"?
> 
> Handled by Dave, see also: Documentation/networking/netdev-FAQ.txt +117

Thanks, good to know! At least I would vote for "Cc: stable".

Michael

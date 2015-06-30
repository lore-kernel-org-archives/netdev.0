From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 16:17:26 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1506301615100.1799@denkbrett>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett> <5592913C.3000207@mellanox.com> <alpine.LFD.2.11.1506301520180.1799@denkbrett> <55929F2D.9050805@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:59410 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbbF3ORa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 10:17:30 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
	Tue, 30 Jun 2015 15:17:28 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0D5A22190046
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 15:17:05 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5UEHRGM37814470
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 14:17:27 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5UEHQ5U000581
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 08:17:27 -0600
In-Reply-To: <55929F2D.9050805@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jun 2015, Or Gerlitz wrote:
> On 6/30/2015 4:24 PM, Sebastian Ott wrote:
> > > >Do you run the VF on the same system/kernel as the PF, or the VF is
> > > >probed to
> > > >VM which runs the latest kernel and the PF runsolder kernel (which?)
> > The latter case. The PF is driven by a much older Kernel running OFED
> > 2.3.2.0.0.1
> >
> 
> Can you try running the inbox PF driver that comes with the PF kernel (what
> kernel is that?) I'd like to see we're OK there.

Frankly, I don't know. Plus I also don't know how to build an ofed kernel.

Regards,
Sebastian

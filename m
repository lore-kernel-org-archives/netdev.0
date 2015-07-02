From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Thu, 2 Jul 2015 11:20:44 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1507021117590.1737@denkbrett>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett> <5592913C.3000207@mellanox.com> <alpine.LFD.2.11.1506301520180.1799@denkbrett> <55929F2D.9050805@mellanox.com> <alpine.LFD.2.11.1506301615100.1799@denkbrett> <5593E88F.10006@mellanox.com>
 <alpine.LFD.2.11.1507011554060.1691@denkbrett> <alpine.LFD.2.11.1507011616560.1691@denkbrett>  <CAJ3xEMhWMAtWhw5Xj+3Pj40FAOSpHGJ3ayGn7WsoHJJEuMZiVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:51709 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbbGBJUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 05:20:51 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
	Thu, 2 Jul 2015 10:20:47 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id D3AE117D805D
	for <netdev@vger.kernel.org>; Thu,  2 Jul 2015 10:21:59 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t629Kk2T38993982
	for <netdev@vger.kernel.org>; Thu, 2 Jul 2015 09:20:46 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t629KjAI009174
	for <netdev@vger.kernel.org>; Thu, 2 Jul 2015 03:20:46 -0600
In-Reply-To: <CAJ3xEMhWMAtWhw5Xj+3Pj40FAOSpHGJ3ayGn7WsoHJJEuMZiVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jul 2015, Or Gerlitz wrote:
> On Wed, Jul 1, 2015 at 5:18 PM, Sebastian Ott <sebott@linux.vnet.ibm.com> wrote:
> > OK, using this patch it worked:
> 
> yep, I forgot to recap err to zero.
> 
> By "it worked" you mean the VF is live and kicking, all functionality
> you had before the 4.2 merge window is back again?
> 

Yes.

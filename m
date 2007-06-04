From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 04 Jun 2007 16:55:29 -0700 (PDT)
Message-ID: <20070604.165529.102446900.davem@davemloft.net>
References: <1180983953.3950.37.camel@localhost.localdomain>
	<Line.LNX.4.64.0706041544230.13341@d.namei>
	<Line.LNX.4.64.0706041911480.15240@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	latten@austin.ibm.com
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759026AbXFDXzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 19:55:16 -0400
In-Reply-To: <Line.LNX.4.64.0706041911480.15240@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 4 Jun 2007 19:13:10 -0400 (EDT)

> I've applied this patch to 
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#for-davem
> 
> 
> Dave, feel free to pull from that branch.

Thanks James, I'll pull that in for my next round of
networking fixes.

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Fri, 11 Jan 2008 21:41:20 +0900 (JST)
Message-ID: <20080111.214120.129309556.yoshfuji@linux-ipv6.org>
References: <20080108011057.GA21168@cisco.com>
	<p73bq7smx1t.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vaf@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34803 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163AbYAKMlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 07:41:19 -0500
In-Reply-To: <p73bq7smx1t.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <p73bq7smx1t.fsf@bingen.suse.de> (at Fri, 11 Jan 2008 12:17:02 +0100), Andi Kleen <andi@firstfloor.org> says:

> Vince Fuller <vaf@cisco.com> writes:
> 
> > from Vince Fuller <vaf@vaf.net>
> >
> > This set of diffs modify the 2.6.20 kernel to enable use of the 240/4
> > (aka "class-E") address space as consistent with the Internet Draft
> > draft-fuller-240space-00.txt.
> 
> Wouldn't it be wise to at least wait for it becoming an RFC first? 

I do think so, too.

There is no positive consesus on this draft
at the intarea meeting in Vancouver, right?

We cannot / should not enable that space until we have reached
a consensus on it.

--yoshfuji

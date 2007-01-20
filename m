From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [PATCH 0/4] spidernet: add support for Celleb
Date: Sat, 20 Jan 2007 22:10:36 +0100
Message-ID: <200701202210.36953.jens@de.ibm.com>
References: <200701171000.l0HA0jnD021501@toshiba.co.jp> <1169081253.4965.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:10880 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965384AbXATVKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 16:10:45 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l0KLAiCn117628
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 21:10:44 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0KLAiss913478
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 21:10:44 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0KLAhId031377
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 21:10:44 GMT
To: linuxppc-dev@ozlabs.org
In-Reply-To: <1169081253.4965.35.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > This is a revised version of the patch set for spider_net driver
> > that works on Toshiba Cell Refererence Set (aka Celleb).
> >
> > This patch set is based on netdev-2.6.git#upstream.
>
> Jens, can you give that a go on our blades see if it doesn't break
> anything ? We are all at LCA here so it's a bit hard to test !

Nope, doesn't work for us...

I have a patch based on Ishizaki's previous patch which I think will work
on Celleb. Will post it here when I have adapted it to the new version.

Jens



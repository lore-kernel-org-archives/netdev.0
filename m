From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Thu, 19 Apr 2007 10:42:53 +0100
Message-ID: <29619.1176975773@redhat.com>
References: <6d6a94c50704181759w12eee19agcb56058b8261dded@mail.gmail.com>  <200704091146.32346.rgetz@blackfin.uclinux.org> <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com> <200704101952.05380.rgetz@blackfin.uclinux.org> <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com> <2817.1176910411@redhat.com>
Cc: "Robin Getz" <rgetz@blackfin.uclinux.org>, uaca@alumni.uv.es,
	bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "Aubrey Li" <aubreylee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161479AbXDSJno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 05:43:44 -0400
In-Reply-To: <6d6a94c50704181759w12eee19agcb56058b8261dded@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aubrey Li <aubreylee@gmail.com> wrote:

> Yes, it's reasonable for me, as long as your
>         host IP is 192.168.2.128
> and
>         target IP is 192.168.2.141

That is correct, yes:-)

I expect it's an NFS packet as my board is using an NFS root at the moment.

David

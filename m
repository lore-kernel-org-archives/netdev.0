From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/1] net: Introduce recvmmsg socket syscall
Date: Tue, 13 Oct 2009 10:14:03 -0300
Message-ID: <20091013131402.GC21809@ghostprotocols.net>
References: <y> <1255364440-23271-1-git-send-email-acme@redhat.com> <20091012.234046.234165425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, caitlin.bestler@gmail.com,
	vanhoof@redhat.com, williams@redhat.com, nhorman@tuxdriver.com,
	nir.tzachar@gmail.com, niv@us.ibm.com, paul.moore@hp.com,
	remi.denis-courmont@nokia.com, steve@chygwyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759812AbZJMNPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 09:15:03 -0400
Content-Disposition: inline
In-Reply-To: <20091012.234046.234165425.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Oct 12, 2009 at 11:40:46PM -0700, David Miller escreveu:
> You missed the syscall entry addition for arch/sparc/kernel/systbls_32.S
> but I fixed that up while applying this to net-next-2.6

Thanks a lot!

- Arnaldo

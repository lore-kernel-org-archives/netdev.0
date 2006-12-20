From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch] handle pktgen setup in newer kernels in iputils/ipg
Date: Thu, 21 Dec 2006 00:23:58 +0900 (JST)
Message-ID: <20061221.002358.08859074.yoshfuji@linux-ipv6.org>
References: <200612201009.04138.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41178 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965125AbWLTPX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 10:23:26 -0500
To: vapier@gentoo.org
In-Reply-To: <200612201009.04138.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200612201009.04138.vapier@gentoo.org> (at Wed, 20 Dec 2006 10:09:03 -0500), Mike Frysinger <vapier@gentoo.org> says:

> the ipg script only works with the old "pg3" module and not the new "pktgen" 
> module ... attached patch updates the ipg script to support both

Applied.  Thanks.

--yoshfuji

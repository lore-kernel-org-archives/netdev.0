From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RESEND [PATCH 2/2] de4x5: Remove developer debug feature about
 set/clear promisc
Date: Tue, 22 Jul 2008 16:09:32 -0400
Message-ID: <48863E7C.8040302@pobox.com>
References: <48856C0B.7090602@cn.fujitsu.com> <48856C6E.5090706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48690 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbYGVUJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 16:09:40 -0400
In-Reply-To: <48856C6E.5090706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> IFF_PROMISC flag shouldn't be set or cleared by drivers, because
> whether device be promisc mode is decided by how many upper layer
> callers being referenced to it.
> And the promisc changing feature of de4x5 ioctl is developer debug
> feature, we can remove it now.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Acked-by: Grant Grundler <grundler@parisc-linux.org>

applied



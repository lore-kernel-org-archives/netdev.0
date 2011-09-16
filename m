From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 0/4] ibmveth fixes
Date: Sat, 17 Sep 2011 06:51:44 +1000
Message-ID: <20110917065144.358da241@kryten>
References: <20110908004102.355674129@samba.org>
	<20110916.152803.861340383634129942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	rcj@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33643 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932186Ab1IPUvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 16:51:50 -0400
In-Reply-To: <20110916.152803.861340383634129942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> All applied.

Thanks!

> I love those "ret1", "ret2", "ret3", "ret4" variables.
> 
> Each successive number in the names gives such incredible
> insight into the meaning and usage of the individual
> variables, making it painless for reviewers to understand
> this code.

:) That function needs to be simplified and rewritten, it took me a
while to get my head around it.

Anton

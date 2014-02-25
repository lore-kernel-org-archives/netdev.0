From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: bpf_dbg: various misc code cleanups
Date: Mon, 24 Feb 2014 19:02:22 -0500 (EST)
Message-ID: <20140224.190222.1618506273966559608.davem@davemloft.net>
References: <1393090673-14669-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaBYACY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:02:24 -0500
In-Reply-To: <1393090673-14669-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 22 Feb 2014 18:37:53 +0100

> Lets clean up bpf_dbg a bit and improve its code slightly
> in various areas: i) Get rid of some macros as there's no
> good reason for keeping them, ii) remove one unused variable
> and reduce scope of various variables found by cppcheck,
> iii) Close non-default file descriptors when exiting the shell.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.

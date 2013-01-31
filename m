From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: add send and receive capability requirement
 and capability flags
Date: Wed, 30 Jan 2013 22:43:22 -0500 (EST)
Message-ID: <20130130.224322.2288389594490040572.davem@davemloft.net>
References: <1358952744-29288-1-git-send-email-rbriggs@redhat.com>
	<20130128.225524.472002600658532532.davem@davemloft.net>
	<20130130185440.GC11492@shell.eng.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rbriggs@redhat.com, netdev@vger.kernel.org, eparis@redhat.com,
	sgrubb@redhat.com
To: rgb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419Ab3AaDnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 22:43:24 -0500
In-Reply-To: <20130130185440.GC11492@shell.eng.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Guy Briggs <rgb@redhat.com>
Date: Wed, 30 Jan 2013 13:54:40 -0500

> Was there any facility that you can think of or point out that could
> provide this functionality?

If you want to provide a pure event stream, why don't you just create
a seperate genetlink instance just for this?

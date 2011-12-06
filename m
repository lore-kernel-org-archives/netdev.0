From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netback: Fix alert message.
Date: Tue, 06 Dec 2011 00:33:00 -0500 (EST)
Message-ID: <20111206.003300.884000484943808807.davem@davemloft.net>
References: <1323104264-3601-1-git-send-email-wei.liu2@citrix.com>
	<1323104325.23681.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068Ab1LFFdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:33:07 -0500
In-Reply-To: <1323104325.23681.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 5 Dec 2011 16:58:45 +0000

> On Mon, 2011-12-05 at 16:57 +0000, Wei Liu wrote:
>> The original message in netback_init was 'kthread_run() fails', which should be
>> 'kthread_create() fails'.
>> 
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks.

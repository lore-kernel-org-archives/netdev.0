From: David Miller <davem@davemloft.net>
Subject: Re: Remove noisy printks from llcp_sock_connect
Date: Thu, 04 Oct 2012 15:59:01 -0400 (EDT)
Message-ID: <20121004.155901.611227116985922660.davem@davemloft.net>
References: <20121004195111.GA31119@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757199Ab2JDT7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 15:59:04 -0400
In-Reply-To: <20121004195111.GA31119@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Thu, 4 Oct 2012 15:51:11 -0400

> Validation of userspace input shouldn't trigger dmesg spamming.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, thanks Dave.

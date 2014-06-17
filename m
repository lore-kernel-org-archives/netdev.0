From: David Miller <davem@davemloft.net>
Subject: Re: tcp: remove unnecessary tcp_sk assignment.
Date: Mon, 16 Jun 2014 21:35:16 -0700 (PDT)
Message-ID: <20140616.213516.360899144328052999.davem@davemloft.net>
References: <20140616203036.GA2879@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbaFQEfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:35:17 -0400
In-Reply-To: <20140616203036.GA2879@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 16 Jun 2014 16:30:36 -0400

> This variable is overwritten by the child socket assignment before
> it ever gets used.
>     
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, thanks Dave.

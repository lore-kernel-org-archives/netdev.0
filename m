From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make tcp_cwnd_application_limited() static
Date: Sun, 20 Apr 2014 18:21:12 -0400 (EDT)
Message-ID: <20140420.182112.946068977361189315.davem@davemloft.net>
References: <e41998355cfed2a278072df2c113b6f89a81dfd0.1397795231.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wpan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbaDTWVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:21:14 -0400
In-Reply-To: <e41998355cfed2a278072df2c113b6f89a81dfd0.1397795231.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <wpan@redhat.com>
Date: Fri, 18 Apr 2014 12:27:46 +0800

> Make tcp_cwnd_application_limited() static and move it from tcp_input.c to
> tcp_output.c
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>

Applied.

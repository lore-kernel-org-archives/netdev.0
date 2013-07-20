From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sysctl net: Keep tcp_syn_retries inside the boundary
Date: Fri, 19 Jul 2013 17:37:21 -0700 (PDT)
Message-ID: <20130719.173721.850231910179318409.davem@davemloft.net>
References: <1374235741-31266-1-git-send-email-mtesar@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mtesar@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab3GTAhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 20:37:22 -0400
In-Reply-To: <1374235741-31266-1-git-send-email-mtesar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Tesar <mtesar@redhat.com>
Date: Fri, 19 Jul 2013 14:09:01 +0200

> Limit the min/max value passed to the
> /proc/sys/net/ipv4/tcp_syn_retries.
> 
> Signed-off-by: Michal Tesar <mtesar@redhat.com>

Applied and queued up for -stable.

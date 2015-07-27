From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] ipv6: Avoid rt6_probe() taking writer
 lock in the fast path
Date: Mon, 27 Jul 2015 01:08:42 -0700 (PDT)
Message-ID: <20150727.010842.295819742135675236.davem@davemloft.net>
References: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbbG0IIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:08:43 -0400
In-Reply-To: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 24 Jul 2015 09:57:41 -0700

> v1 -> v2:
> 1. Separate the code re-arrangement into another patch
> 2. Fix style

Looks good, series applied.

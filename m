From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/7] fix checkpatch errors
Date: Thu, 26 Dec 2013 13:44:17 -0500 (EST)
Message-ID: <20131226.134417.1986910506759819708.davem@davemloft.net>
References: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3LZSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:44:20 -0500
In-Reply-To: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Weilong <chenweilong@huawei.com>
Date: Mon, 23 Dec 2013 10:14:09 +0800

> Weilong Chen (7):
>   ipv4: do clean up with spaces
>   ipv4: fix checkpatch error "space prohibited XXX"
>   ipv4: fix checkpatch error with foo * bar
>   ipv4: fix all space errors in file igmp.c
>   ipv4: ERROR: do not initialise globals to 0 or NULL
>   ipv4: ERROR: code indent should use tabs where possible
>   ipv4: ERROR: do not use C99 // comments

Series applied, thanks.

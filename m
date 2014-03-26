From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net: tcp_ipv6 do some cleanup
Date: Wed, 26 Mar 2014 15:42:55 -0400 (EDT)
Message-ID: <20140326.154255.1270995413257461102.davem@davemloft.net>
References: <1395642322-9404-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbaCZTm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:42:57 -0400
In-Reply-To: <1395642322-9404-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wangyufen <wangyufen@huawei.com>
Date: Mon, 24 Mar 2014 14:25:21 +0800

> -static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
> +static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
>  				  int optlen)

If you change the first line, you must adjust the indentation of the second
line so that "int optlen)" begins precisely at the first column after the
openning parenthesis on the first line.

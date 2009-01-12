From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] NET: fix wrong English expression in comments
Date: Mon, 12 Jan 2009 09:05:23 +0800
Message-ID: <496A9753.80802@cn.fujitsu.com>
References: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Qinghuang Feng <qhfeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54551 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbZALBGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 20:06:23 -0500
In-Reply-To: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -103,7 +103,7 @@ struct inet_bind_bucket;
>  struct inet_timewait_sock {
>  	/*
>  	 * Now struct sock also uses sock_common, so please just
> -	 * don't add nothing before this first member (__tw_common) --acme
> +	 * don't add anything before this first member (__tw_common) --acme

They are the same meaning...

>  	 */
>  	struct sock_common	__tw_common;
>  #define tw_family		__tw_common.skc_family

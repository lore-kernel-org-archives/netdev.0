From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 12/18] netdevice hdlc: Convert directly reference of netdev->priv to netdev->ml_priv
Date: Fri, 05 Sep 2008 18:38:35 +0200
Message-ID: <m31vzy4kfo.fsf@maximus.localdomain>
References: <48C0A219.2030004@cn.fujitsu.com>
	<48C0A672.9080102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:40560 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075AbYIEQih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 12:38:37 -0400
In-Reply-To: <48C0A672.9080102@cn.fujitsu.com> (Wang Chen's message of "Fri\, 05 Sep 2008 11\:24\:34 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen <wangchen@cn.fujitsu.com> writes:

> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
> ---
>  drivers/net/wan/hdlc_fr.c |   10 +++++-----
>  include/linux/hdlc.h      |    2 +-
>  2 files changed, 6 insertions(+), 6 deletions(-)

Since it's now a separate patch I will just take it.
Thanks.
-- 
Krzysztof Halasa

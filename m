From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 9/15] netdevice hdlc: Convert directly reference of netdev->priv to netdev_priv()
Date: Tue, 26 Aug 2008 18:35:34 +0200
Message-ID: <m3wsi3wx7t.fsf@maximus.localdomain>
References: <48B3D717.7070706@cn.fujitsu.com>
	<48B3DA32.4030306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:44945 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753373AbYHZQfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 12:35:39 -0400
In-Reply-To: <48B3DA32.4030306@cn.fujitsu.com> (Wang Chen's message of "Tue\, 26 Aug 2008 18\:25\:54 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen <wangchen@cn.fujitsu.com> writes:

> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/net/wan/hdlc_fr.c |   10 +++++-----
>  include/linux/hdlc.h      |    2 +-
>  2 files changed, 6 insertions(+), 6 deletions(-)

Looks good, thanks/Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
-- 
Krzysztof Halasa

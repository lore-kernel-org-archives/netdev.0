From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 17/18] netdevice pc300: Convert directly reference of netdev->priv to netdev->ml_priv
Date: Tue, 09 Sep 2008 15:23:19 +0200
Message-ID: <m38wu1tpvc.fsf@maximus.localdomain>
References: <48C0A219.2030004@cn.fujitsu.com>
	<48C0A7D9.8090306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35073 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774AbYIINXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 09:23:21 -0400
In-Reply-To: <48C0A7D9.8090306@cn.fujitsu.com> (Wang Chen's message of "Fri\, 05 Sep 2008 11\:30\:33 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen <wangchen@cn.fujitsu.com> writes:

>  drivers/net/wan/pc300_drv.c |   17 +++++++++--------
>  1 files changed, 9 insertions(+), 8 deletions(-)

I think I'll also take this. Though I don't yet know what to do with
this driver. Perhaps I should fix it somehow or merge with pc300too.

Thanks.
-- 
Krzysztof Halasa

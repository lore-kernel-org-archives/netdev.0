From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Fri, 05 Dec 2014 21:46:41 -0800
Message-ID: <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
	 <20141205.213112.1199355931404701216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org,
	gideonn@mellanox.com, edumazet@google.com, amirv@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39557 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbaLFFqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:46:44 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so2012445ieb.3
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 21:46:44 -0800 (PST)
In-Reply-To: <20141205.213112.1199355931404701216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 21:31 -0800, David Miller wrote:

> Guys, let's figure out what we are doing with this patch.
> --

Oh well, patch is fine, please apply it, thanks !

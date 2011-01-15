From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH net-next] net: cleanup unused macros in net directory
Date: Sat, 15 Jan 2011 14:59:54 +0100
Message-ID: <AANLkTikBObita8BjHaphpjpVOpWw2SK1ZSVPR79YNCh4@mail.gmail.com>
References: <4D300728.8030402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andy.grover@oracle.com,
	ericvh@gmail.com, jvrao@us.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, joe@perches.com,
	Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, jpirko@redhat.com,
	nhorman@tuxdriver.com, pebolle@tiscali.nl, jkosina@suse.cz,
	arnd@arndb.de, Network-Maillist <netdev@vger.kernel.org>,
	linux-decnet-user@lists.sourceforge.net, rds-devel@oss.oracle.com
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52725 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210Ab1AON74 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 08:59:56 -0500
Received: by fxm20 with SMTP id 20so3920134fxm.19
        for <netdev@vger.kernel.org>; Sat, 15 Jan 2011 05:59:54 -0800 (PST)
In-Reply-To: <4D300728.8030402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Clean up some unused macros in net/*.
> 1. be left for code change. e.g. PGV_FROM_VMALLOC, PGV_FROM_VMALLOC, =
KMEM_SAFETYZONE.
> 2. never be used since introduced to kernel.
> =C2=A0 e.g. P9_RDMA_MAX_SGE, UTIL_CTRL_PKT_SIZE.
>
>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

CAIF parts looks ok to me (reviewed only).

Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

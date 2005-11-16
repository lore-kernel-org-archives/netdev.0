From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]small fix for __ipv6_addr_type(...)
Date: Wed, 16 Nov 2005 10:10:57 +0900 (JST)
Message-ID: <20051116.101057.23968406.yoshfuji@linux-ipv6.org>
References: <4376F2CE.4050003@21cn.com>
	<437A5F42.3080100@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965148AbVKPBKZ@vger.kernel.org>
To: vladislav.yasevich@hp.com
In-Reply-To: <437A5F42.3080100@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <437A5F42.3080100@hp.com> (at Tue, 15 Nov 2005 17:20:50 -0500), Vlad Yasevich <vladislav.yasevich@hp.com> says:

> No, according to RFC 4007, loopback is considered a link-local
> address.

Agreed. RFC3484 also explicitly says that loopback is treated as link-local.

--yoshfuji

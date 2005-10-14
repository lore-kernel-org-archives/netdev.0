From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: [PATCH]The type of inet6_ifinfo_notify event in
 addrconf_ifdown().
Date: Fri, 14 Oct 2005 19:53:15 +0900 (JST)
Message-ID: <20051014.195315.106624870.yoshfuji@wide.ad.jp>
References: <434F8B23.7090201@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@wide.ad.jp
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750715AbVJNKx2@vger.kernel.org>
To: yzcorp@gmail.com, davem@davemloft.net
In-Reply-To: <434F8B23.7090201@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <434F8B23.7090201@gmail.com> (at Fri, 14 Oct 2005 18:40:35 +0800), Yan Zheng <yzcorp@gmail.com> says:

> Maybe inet6_ifinfo_notify event type should be RTM_DELLINK in 
> addrconf_ifdown().
> 
> Signed-off-by: Yan Zheng<yanzheng@21cn.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji

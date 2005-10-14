From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]The type of inet6_ifinfo_notify event in
 addrconf_ifdown().
Date: Fri, 14 Oct 2005 13:57:51 -0700 (PDT)
Message-ID: <20051014.135751.78051480.davem@davemloft.net>
References: <434F8B23.7090201@gmail.com>
	<20051014.195315.106624870.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yzcorp@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750898AbVJNU6A@vger.kernel.org>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20051014.195315.106624870.yoshfuji@wide.ad.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@wide.ad.jp>
Date: Fri, 14 Oct 2005 19:53:15 +0900 (JST)

> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.  I also took the liberty of fixing the "Step 5"
comment above, it should be "Step 6" :-)

Yan, please fix your patch postings.  Your email client
adds newlines, and changes tabs into spaces, totally corrupting
your patches.  I have to apply every one of your patches by
hand because of this.

To be honest, gmail has been shown to be a very unusable place
from which to send patches.  There are certain kinds of outgoing
text mangling that I do not know if they even allow to disable.

Thanks.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [XFRM] xfrm_alloc_spi() always selected minspi
Date: Sun, 15 Jun 2003 00:29:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615.002946.15265501.davem@redhat.com>
References: <20030614.111619.37286104.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030614.111619.37286104.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Sat, 14 Jun 2003 11:16:19 +0900 (JST)

   net/xfrm/xfrm_state.c:xfrm_alloc_spi() always selected minspi
   because of typo.
 ...   
   Here's the fix.

Patch applied, thanks.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Tue, 08 Oct 2002 12:40:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021008.124002.06553598.davem@redhat.com>
References: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>
	<20021007.115530.00078126.davem@redhat.com>
	<20021008.093721.11469009.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021008.093721.11469009.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 08 Oct 2002 09:37:21 +0900 (JST)

   So,... What kind of patches do you prefer, now?
   
    - on top of plain kernel (2.4.19, 2.4.20, 2.4.21-preXX, or whatever)
    - plain kernel + on top of our whole patch?
    - ???

If you send patches against 2.4.20-pre9, it would be fine.

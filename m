From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6] [IPV6] SIT: dst leakage in error path.
Date: Sat, 02 Oct 2004 19:34:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002.193424.76694251.yoshfuji@linux-ipv6.org>
References: <20041002.193138.94763422.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20041002.193138.94763422.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041002.193138.94763422.yoshfuji@linux-ipv6.org> (at Sat, 02 Oct 2004 19:31:38 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> We failed to put rt in error path.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

And this also applies 2.4 (with some fuzz).

--yoshfuji

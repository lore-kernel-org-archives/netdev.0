From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: fix checking for reserved subnet anycast
Date: Mon, 2 Feb 2004 10:36:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040202103649.32e4a9b2.davem@redhat.com>
References: <20040203.020741.105137354.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20040203.020741.105137354.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Feb 2004 02:07:41 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp> wrote:

> Reserved subnet anycast is as follows:
>    11111101 11....11 1xxxxxxx
> The code checking for reserved subnet anycast in 
> __ipv6_regen_rndid() was incorrect.
> 
> D: fix checking for reserved subnet anycast in __ipv6_regen_rndid().

Applied, thanks.

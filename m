From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [IPV6] fix flags for ndisc dst
Date: Mon, 5 Jul 2004 16:40:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705164042.0493f4c2.davem@redhat.com>
References: <20040705.162838.67048785.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040705.162838.67048785.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 05 Jul 2004 16:28:38 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Because RTF_LOCAL is for local unicast address, 
> it was wrong to set RTF_LOCAL to ndisc dst.
> This patch also adds some comment on other fields.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK-PATCH 2.6] IPV6: Fix checksum for rawv6 sockets
Date: Thu, 20 May 2004 08:16:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520081631.78157bf1.davem@redhat.com>
References: <20040520.193240.67952249.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040520.193240.67952249.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 May 2004 19:32:40 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Following changesets fixes checksum for rawv6 sockets.
>  - send appropriate checksum
>  - don't receive packets with incorrect checksum
>  - ensure to notify return code to the caller.
> 
> Please pull following csets from <bk://bk.skbuff.net:20606>.

This looks great.  Pulled, thanks a lot Yoshfuji.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: clean-up ndisc printk's
Date: Wed, 11 Feb 2004 11:16:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211111616.34c18a2c.davem@redhat.com>
References: <20040210.164650.109511390.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040210.164650.109511390.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2004 16:46:50 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> D: print KERN_xxx appropriately.
> D: put net_ratelimit() inside the macro.
> D: re-arrange levels.

Looks OK, applied.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 1/2] IPV6: use ipv6_addr_any()
Date: Wed, 28 Jan 2004 16:06:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128160603.10491a21.davem@redhat.com>
References: <20040128.163043.120256112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040128.163043.120256112.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004 16:30:43 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Use simple ipv6_addr_any()
> where ipv6_addr_type() is called only to check for unspecified address.

Applied.  Arigato Yoshfuji-san.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: Oops: Process zebra, EIP is at fib_create_info+0x22b/0x580
Date: Sat, 21 Aug 2004 22:17:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821221751.547feefe.davem@redhat.com>
References: <20040821210417.GA8844@hamsu.derbian.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joonas Kortesalmi <vrsbs@derbian.org>
In-Reply-To: <20040821210417.GA8844@hamsu.derbian.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 22 Aug 2004 00:04:17 +0300
Joonas Kortesalmi <vrsbs@derbian.org> wrote:

> Running 2.6.8.1 and got a nice Oops from zebra (quagga).

Can you figure out where exactly this OOPS is in fib_create_info()?

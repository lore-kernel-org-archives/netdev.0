From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: Fix BUG when appending destination options headers
Date: Wed, 9 Jul 2003 01:27:59 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307090127170.8792-100000@excalibur.intercode.com.au>
References: <20030708.221834.127574909.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>, Thomas Graf <tgr@reeler.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030708.221834.127574909.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> This patch fixes BUG when pushing IPv6 destination options over an
> IPv6 raw socket.  Patch is based on one from Thomas Graf <tgr@reeler.org>.

Applied to bk://kernel.bkbits.net/jmorris/ipv6-2.5


- James
-- 
James Morris
<jmorris@intercode.com.au>

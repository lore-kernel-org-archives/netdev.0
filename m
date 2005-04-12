From: Roger Luethi <rl@hellgate.ch>
Subject: Re: VIA Rhine ethernet driver bug
Date: Tue, 12 Apr 2005 17:27:22 +0200
Message-ID: <20050412152721.GB8897@k3.hellgate.ch>
References: <000501c53da5$944b05d0$450aa8c0@hierzo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Udo van den Heuvel <udovdh@xs4all.nl>
Content-Disposition: inline
In-Reply-To: <000501c53da5$944b05d0$450aa8c0@hierzo>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 10 Apr 2005 10:16:21 +0200, Udo van den Heuvel wrote:
> Apr  8 18:51:08 epia kernel: eth1: Oversized Ethernet frame spanned multiple
> buffers, entry 0x9 length 0 status 00000600!

It's been a while since I looked into this, but here's what I remember:
This is not supposed to happen. Because this is so peculiar, I talked
it over with VIA, and they want to know whether their own driver makes
any difference. I relayed that request to you, but I don't remember
ever getting a report back. Did I miss something?

Roger

From: "David S. Miller" <davem@redhat.com>
Subject: Re: tcp socket missing from /proc/net/tcp
Date: Sat, 23 Aug 2003 21:20:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030823212055.4d8e41ef.davem@redhat.com>
References: <m3lltk17er.fsf@lugabout.jhcloos.org>
	<20030823172710.478f30f9.davem@redhat.com>
	<20030824.100753.63798138.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cloos@jhcloos.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030824.100753.63798138.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 24 Aug 2003 10:07:53 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> net/ipv4/tcp_ipv4.c:tcp_proc_register() called by tcp6_proc_init() does this.
> Or, do I miss something?

You're right, I missed that.

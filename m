From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: add missing sentinel for addrconf procfs
Date: Wed, 21 Jan 2004 22:11:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121221142.1786ca19.davem@redhat.com>
References: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
	<20040120104820.77ff135f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040120104820.77ff135f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 20 Jan 2004 10:48:20 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Tue, 20 Jan 2004 09:42:23 +0900 (JST)
> YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org> wrote:
> 
> > Sorry, I forgot to increase the number of members in the array and 
> > that the sentinel was removed.
> > So, add missing sentinel explicitly.
> 
> How about adding all them explicitly to prevent future errors?

Applied, thanks Stephen.

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Thu, 21 Oct 2004 14:50:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021145053.6d87f32d@zqx3.pdx.osdl.net>
References: <20041021133752.67a386fb@zqx3.pdx.osdl.net>
	<20041021142335.54f088ad.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041021142335.54f088ad.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 14:23:35 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 21 Oct 2004 13:37:52 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> >            Summary: kernel-2.6.9 breaks Amanda
> 
> Unfortunately, he failed to show the tcpdump traces of the UDP
> traffic as he did in his lkml postings.  There you will find
> checksum errors mentioned in the tcpdump output for the last
> few consequetive UDP packets and I think that is a good clue
> as to what may be the problem here.

Since it is reproducible, I already requested a tcpdump trace.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: iproute2 and kernel headers
Date: Mon, 2 Aug 2004 16:04:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802160445.5ef3b251.davem@redhat.com>
References: <20040802153805.487f832f@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@znyx.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040802153805.487f832f@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Aug 2004 15:38:05 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> I am willing to put some headers (not all) in with the user level
> code, provided they are copies since they I can easily update. I don't want
> to get into keeping an edited set of headers in sync.
> 
> What headers really seem to change a lot? The obvious ones are:
> 
> 	linux/pkt_sched.h
> 	linux/tcp_diag.h
> 	linux/xfrm.h

I would add linux/rtnetlink.h

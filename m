From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] add sysctl to turn off caching metrics
Date: Wed, 21 Apr 2004 17:01:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421170115.5c9017dd.davem@redhat.com>
References: <20040420155738.4146b5bb.davem@redhat.com>
	<20040421111046.34bf3e73@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040421111046.34bf3e73@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 Apr 2004 11:10:46 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> When running benchmarks and other experiments, it is often useful
> not to save the route metrics (cwnd, rtt) from each connection.
> Here is a simple way to do it with sysctl.  Not a new idea, it is part
> of the web100 stuff as well.

This is fine.

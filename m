From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] mark CSZ scheduler as broken
Date: Fri, 9 Jul 2004 16:15:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709161552.3785869a.davem@redhat.com>
References: <20040707111936.760586b0@dell_ss3.pdx.osdl.net>
	<20040707152803.6e2a7336.davem@redhat.com>
	<20040707165628.02246aaf@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707165628.02246aaf@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004 16:56:28 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> It builds fine and obeys all the conventions, so it isn't really BROKEN like
> other drivers. But do we really want to keep it in the tree at all?  The code to
> set it up isn't in the any version of 'tc' I saw (only stubs).

Ok, I've been thinking about this a bit and we can just
kill it from the 2.6.x tree.

I'll do that.

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] mark CSZ scheduler as broken
Date: Wed, 7 Jul 2004 16:56:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707165628.02246aaf@dell_ss3.pdx.osdl.net>
References: <20040707111936.760586b0@dell_ss3.pdx.osdl.net>
	<20040707152803.6e2a7336.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040707152803.6e2a7336.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004 15:28:03 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Wed, 7 Jul 2004 11:19:36 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Since the configuration help for CSZ is broken, and other documentation
> > says it just doesn't work.  Why not mark it as broken to make it obvious?
> 
> I think marking it as experimental is more appropriate and
> accurate.  Don't you think?

It builds fine and obeys all the conventions, so it isn't really BROKEN like
other drivers. But do we really want to keep it in the tree at all?  The code to
set it up isn't in the any version of 'tc' I saw (only stubs).

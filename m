From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] netdev_ops
Date: Mon, 14 Jul 2003 02:53:54 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714055354.GP3825@conectiva.com.br>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <20030711193215.GH16037@gtf.org> <20030711200423.GL20424@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
   greearb@candelatech.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030711200423.GL20424@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Jul 11, 2003 at 09:04:23PM +0100, Matthew Wilcox escreveu:
> On Fri, Jul 11, 2003 at 03:32:15PM -0400, Jeff Garzik wrote:
> > 1) The _ops are either too limited in scope, or too wide in scope.
> 
> Couldn't agree more.  I blame acme -- he wants me to push it to be much
> wider in scope.  Let's push _all_ the function pointers into netdev_ops.

Hey, it was just a brainstorm session ;) Anyway, I'm heavily backlogged as
I'm on a business trip for several days already, I'll try to read all this
thread when I'm back home 8)

- Arnaldo

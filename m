From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Thu, 27 May 2004 10:12:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527001221.GE5958@sgi.com>
References: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com> <20040526160443.GD4557@sgi.com> <20040526110121.657f2d42.davem@redhat.com> <20040526234732.GA5958@sgi.com> <20040526165238.60eae8ff.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040526165238.60eae8ff.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2004 at 04:52:38PM -0700, David S. Miller wrote:
> On Thu, 27 May 2004 09:47:33 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > If we can show a performance improvement on our hardware, would you
> > accept a patch to enable host send rings on our hardware only?
> 
> Did you read my other email?  I already made the change globally
> in my sources.  tg3 will always use host send rings now.

Sorry, I'm using a crappy text mail tool over dialup at the moment
which makes it hard to scan ahead for complete state before replying.

I'm very happy about the change, thanks!

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

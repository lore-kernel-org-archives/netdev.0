From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH][ATM][2.4] export try_atm_clip_ops not atm_clip_ops_mutex
Date: Wed, 30 Jul 2003 10:24:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730102437.B3901@infradead.org>
References: <200307291759.h6THxlsG028613@ginger.cmf.nrl.navy.mil> <20030729223327.5575a154.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030729223327.5575a154.davem@redhat.com>; from davem@redhat.com on Tue, Jul 29, 2003 at 10:33:27PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 29, 2003 at 10:33:27PM -0700, David S. Miller wrote:
> On Tue, 29 Jul 2003 13:57:05 -0400
> chas williams <chas@cmf.nrl.navy.mil> wrote:
> 
> > please apply to 2.4 -- thanks
> > 
> > [atm]: export try_atm_clip_ops not atm_clip_ops_mutex
> 
> Applied, will go into 2.4.23-preX

Hmm, this looks like a fix for modular compilation and should
probably go into 2.4.22..

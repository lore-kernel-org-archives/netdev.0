From: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
Subject: Re: [PATCH] tcp: efficient port randomistion (rev 3)
Date: Wed, 22 Jun 2005 11:17:03 +0200
Message-ID: <200506221117.04334.michael.vittrup.larsen@ericsson.com>
References: <20041220153916.6c00c114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041220153916.6c00c114.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 21 December 2004 00:39, David S. Miller wrote:
> On Fri, 10 Dec 2004 17:09:00 -0800
>
> Stephen Hemminger <shemminger@osdl.org> wrote:
> > okay, here is the revised version. Testing shows that it
> > is more consistent, and just as fast as existing code,
> > probably because of the getting rid of portalloc_lock and
> > better distribution.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> Queued up for 2.6.11, thanks Stephen.

What's the status of this - I see it is not part of 2.6.12?

Is there a general dislike of the port randomisation mechanism or?

/Michael

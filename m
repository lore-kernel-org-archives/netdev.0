From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.6.0-bk6 net/core/dev.c
Date: Thu, 25 Sep 2003 03:01:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925030109.09bbedca.davem@redhat.com>
References: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
	<1064423867.15283.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1064423867.15283.11.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Sep 2003 10:17:47 -0700
Joe Perches <joe@perches.com> wrote:

> On Wed, 2003-09-24 at 10:13, Linus Torvalds wrote:
> > Looks sane, but wouldn't it be cleaner to put this ugly special case logic
> > with casts etc in an inline function and make the code a bit more readable
> > at the same time?
> 
> I've got those.
> 
> I've done the ((void*)1) conversions to PKT_SHARED_SKBs
> and found this missing.  I'll submit those separately.

Send me what you have and I'll review and apply it.

I haven't accomplished anything today because I've been sick,
but tomorrow I should be back to full speed once more.

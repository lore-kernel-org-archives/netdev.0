From: Dan Aloni <da-x@gmx.net>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network device renaming, for ipv4
Date: Mon, 1 Sep 2003 19:55:59 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901165559.GA27099@callisto.yi.org>
References: <20030901164624.GA26886@callisto.yi.org> <20030901094127.6a0f6878.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030901094127.6a0f6878.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 01, 2003 at 09:41:27AM -0700, David S. Miller wrote:
> On Mon, 1 Sep 2003 19:46:24 +0300
> Dan Aloni <da-x@gmx.net> wrote:
> 
> > Can you please take a look and comment?
> 
> I commented already and I said "putting a private copy
> of a generic function like strdup() in the middle of
> the networking code is inappropriate."

For some unknown reason I didn't get that response.

The private copy of strdup() is something that I'd also wouldn't
want, but I don't have much choice. Please read a recent 
thread in lkml regarding strdup() consolidation.

-- 
Dan Aloni
da-x@gmx.net

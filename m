From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network
 device renaming, for ipv4
Date: Mon, 20 Oct 2003 22:57:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020225717.5619e9bf.davem@redhat.com>
References: <20030901164624.GA26886@callisto.yi.org>
	<20030901094127.6a0f6878.davem@redhat.com>
	<20030901165559.GA27099@callisto.yi.org>
	<20030901113143.1ba34464.davem@redhat.com>
	<20031017213235.GA5278@callisto.yi.org>
	<20031018000131.52a13c98.davem@redhat.com>
	<20031018112011.GA16613@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Aloni <da-x@gmx.net>
In-Reply-To: <20031018112011.GA16613@callisto.yi.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 13:20:11 +0200
Dan Aloni <da-x@gmx.net> wrote:

> On Sat, Oct 18, 2003 at 12:01:31AM -0700, David S. Miller wrote:
> > On Fri, 17 Oct 2003 23:32:35 +0200
> > Dan Aloni <da-x@gmx.net> wrote:
> > 
> > > Here is the patch. I've compiled and tested it.
> > 
> > But not with ipv6 modular :-)  Please add the necessary
> > module symbol export for net_sysctl_strdup() and resubmit
> > the patch.
> 
> Of course, what was I thinking.

Applied, thanks Dan.

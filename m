From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 13:32:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910203203.GA17078@bougret.hpl.hp.com>
References: <20040910195003.GA13912@bougret.hpl.hp.com> <20040910200644.GJ20088@postel.suug.ch> <20040910201302.GA16556@bougret.hpl.hp.com> <20040910202235.GK20088@postel.suug.ch>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20040910202235.GK20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 10, 2004 at 10:22:35PM +0200, Thomas Graf wrote:
> 
> 2) Implement NETDEV_CHANGE, I was actually about to implement this
>    but it's not directly related to this change and requires the same
>    effort by the user space application has refetching the link list.

	Do you have any info on NETDEV_CHANGE, I've got a potential
use for it.
	(By the way, there are other ways to do it, but if
NETDEV_CHANGE is the proposed standard, I might as well use it).

	Jean

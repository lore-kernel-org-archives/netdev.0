From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: 10 Sep 2004 16:31:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094848300.1029.17.camel@jzny.localdomain>
References: <20040910195003.GA13912@bougret.hpl.hp.com>
	 <20040910200644.GJ20088@postel.suug.ch>
	 <20040910201302.GA16556@bougret.hpl.hp.com>
	 <20040910202235.GK20088@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040910202235.GK20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-10 at 16:22, Thomas Graf wrote:

> 2) Implement NETDEV_CHANGE, I was actually about to implement this
>    but it's not directly related to this change and requires the same
>    effort by the user space application has refetching the link list.

This is what he needs. Essentially NETDEV_CHANGE will generate a netlink
event.

cheers,
jamal

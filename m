From: Thomas Graf <tgraf@suug.ch>
Subject: Re: RFC:  Redirect-Device
Date: Fri, 1 Apr 2005 00:46:40 +0200
Message-ID: <20050331224640.GC3086@postel.suug.ch>
References: <424C6089.1080507@candelatech.com> <1112303627.1073.71.camel@jzny.localdomain> <424C6B10.6030200@candelatech.com> <1112306031.1073.109.camel@jzny.localdomain> <424C7813.4000101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <424C7813.4000101@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ben Greear <424C7813.4000101@candelatech.com> 2005-03-31 14:22
> My personal opinion is that netlink sockets are a pain in the ass to deal
> with, and there is no way I want to try to programatically parse the tc
> input or output.

libnl will make your life a lot easier, the tc support is not yet
finished but I'll be releasing a version this week which at least
fully support all the basics (link, neigh, address, routes, rules).
It's only a matter of time until one can use the tc interface with
only a few library calls.

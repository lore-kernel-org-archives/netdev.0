From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] Allow setting dev->weight using ip(8)
Date: Wed, 8 Sep 2004 15:45:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908134551.GP31616@rei.reeler.org>
References: <5cac192f040830035669628d1@mail.gmail.com> <1093868860.1075.573.camel@jzny.localdomain> <5cac192f0408300733477c6c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
Content-Disposition: inline
In-Reply-To: <5cac192f0408300733477c6c9@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Lemoine <5cac192f0408300733477c6c9@mail.gmail.com> 2004-08-30 16:33
> iproute still uses ioctl at that time, doesn't it?
> [...]
> I attached a patch to iproute-2.6.8. To make the patch compile I had
> to tinker with the Makefile - it seems that KERNEL_INCLUDE does no
> longer serve any purpose, except for ATM maybe.

I have a patch for it and added support for your new changes.
I'm currently holding it back until all issues with the 2.4
backport have been solved.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Bogus return status in drivers/net/tg3.c
Date: Fri, 19 Dec 2003 21:54:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031219215442.1947cdb1.davem@redhat.com>
References: <20031219233231.A2420@electric-eye.fr.zoreil.com>
	<20031219214455.28f22d60.davem@redhat.com>
	<3FE3E2D7.7070004@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FE3E2D7.7070004@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Dec 2003 00:49:11 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Up to you.  Either way I want to make sure it goes into 
> net-drivers-2.5-exp, which has your current tg3-2.5 tree up until now.

I'm concerned how difficult it will be for you to push the
net-drivers-2.5-exp tree into 2.6.x any time soon.

Let's create a no lose situation :)  I'll toss it into my tree and
you toss it into your's and this way it'll get in somehow.

From: kuznet@ms2.inr.ac.ru
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Tue, 15 Jul 2003 03:49:43 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307142349.DAA06134@dub.inr.ac.ru>
References: <20030710.214551.08349572.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030710.214551.08349572.davem@redhat.com> from "David S. Miller" at éÀÌ 10, 2003 09:45:51 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Alexey, please add some sanity to this discussion.

It is about anycast addresses, I maybe not competent here.
I have no idea what is purpose of all-routers anycast.

However, my modest opinion is here:

IN NO WAY ANYCAST ADDRESSES MAY BE USED AS NEXTHOP ADDRESSES.
NEXTHOP ADDRESS IS THE ADDRESS WHICH IS EXPECTED TO BE SOURCE OF REDIRECT
MESSAGES ET AL. ANYCAST ADDRESSES ARE INVALID AS SOURCE, HENCE...

Period.

Alexey

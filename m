From: Pekka Savola <pekkas@netcore.fi>
Subject: Any effort to try to make IPv6 API more uniform?
Date: Fri, 27 Sep 2002 08:59:49 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209270855280.29884-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

In addition to IPv6 Basic & Advanced Sockets API document, I had a worry 
whether there would be any use trying to make some other API's more 
useful.

For example, currently there is no standard (or even "semi-standard") way 
of getting IPv6 address(es) of a node.  With IPv4 you can get this via 
ioctls or e.g. netlink.  Netlink is notably a Linux-only thing.

For application portability I would gather it might be nice to have some, 
if not a standard, at least something many similar vendors (e.g. Unix, 
Linux+BSD, ...) support.

Any thoughts whether this would be useful and what would be the right 
path to take?

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

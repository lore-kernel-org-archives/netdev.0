From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Fw: [Bugme-new] [Bug 4131] New: iptables rules don't work
	correctly in 2.6.11-rc2-bk7
Date: Mon, 31 Jan 2005 14:39:53 +1100
Message-ID: <1107142793.28143.3.camel@localhost.localdomain>
References: <20050129234832.53c6f763.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, selecter@spray.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050129234832.53c6f763.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-29 at 23:48 -0800, Andrew Morton wrote:
> Also I can't see connection state match support in menuconfig

Well, that would do it.  Do you have connection tracking configured in?
Otherwise you won't get asked for state.

Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman

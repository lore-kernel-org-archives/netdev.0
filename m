From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ing_filter debug messages
Date: Fri, 31 Dec 2004 16:48:44 +0100
Message-ID: <20041231154844.GA11511@wiggy.net>
References: <20041230160643.GD24603@wiggy.net> <1104469666.1049.231.camel@jzny.localdomain> <20041231093827.GG24603@wiggy.net> <1104491510.1047.234.camel@jzny.localdomain> <20041231131553.GA7460@wiggy.net> <1104505838.1048.273.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104505838.1048.273.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously jamal wrote:
> Try also the attached patch with netfilter on and your rules installed.

That seems to do the trick: I no longer see the debug messages appear.
The tunnel still works as well.

However, the unregister_netdev problem still persists.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.

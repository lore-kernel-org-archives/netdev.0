From: Michael Renzmann <mrenzmann@web.de>
Subject: Re: Fw: [Bugme-new] [Bug 3777] New: tun driver fails to open when
 built in, must be modular
Date: Sat, 20 Nov 2004 06:27:39 +0100
Message-ID: <419ED5CB.3080106@web.de>
References: <20041119150808.578154d3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20041119150808.578154d3.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Andrew Morton wrote:
> Problem Description: kernel will not assign/open a tun device when tun.o is
> compiled as a built-in. ifconfig gives 'unable to open /dev/net/tun' error.
> compiling as a module fixes.

If anyone can give me a small general hints for what might be the cause 
of this problem, I could take a look at it. I already have some patches 
for tun.o (that needs to be sent to the maintainer), another one doesn't 
hurt :) But since I'm not yet too experienced with programming of kernel 
modules, any help would be appreciated.

Bye, Mike

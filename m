From: Johannes Stezenbach <js@linuxtv.org>
Subject: Re: 2.6.11: USB broken on nforce4, ipv6 still broken, centrino speedstep even more broken than in 2.6.10
Date: Tue, 22 Mar 2005 17:22:03 +0100
Message-ID: <20050322162203.GB19668@linuxtv.org>
References: <20050311202122.GA13205@fefe.de> <20050311173308.7a076e8f.akpm@osdl.org> <20050321163358.1b4968a0.akpm@osdl.org> <20050322021857.GA17972@linuxtv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@osdl.org>, felix-linuxkernel@fefe.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050322021857.GA17972@linuxtv.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Johannes Stezenbach wrote:
> Grab the ncp package from http://www.fefe.de/ncp/, or more specifically
> ftp://ftp.fu-berlin.de/unix/network/ncp/ncp-1.2.3.tar.bz2.
> 
> It's a very useful and handy tool for pushing around data within
> a LAN of a small workgroup, one guy does "npush foo" and yells
> at the intended recepient "do npoll". The first one to do
> it wins and gets foo ;-)

In case that description sounded too silly: The essential feature
of ncp is that it requires no configuration or installation of a
server daemon, and you don't even need to worry about host names or the
IP address of the source or destination machine. Just hook two computers
to the same network and you're ready to npush/npoll. Similar to
netcat + tar, but way more convenient.

Johannes

From: Andrew McGregor <andrew@indranet.co.nz>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Fri, 10 Jan 2003 14:17:52 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1291230000.1042161472@localhost.localdomain>
References: <20030108130850.GQ22951@wiggy.net>
 <20030109123857.A15625@bitwizard.nl> <20030109155214.GX22951@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
In-Reply-To: <20030109155214.GX22951@wiggy.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, January 09, 2003 16:52:14 +0100 Wichert Akkerman 
<wichert@wiggy.net> wrote:

> Previously Rogier Wolff wrote:
>> Can you check the stats counters, to see if they are indeed dropped?
>
> It seems no packets are dropped:
>

...

> Tcp:
>     666 active connections openings
>     0 passive connection openings
>     0 failed connection attempts
>     0 connection resets received
>     2 connections established
>     58949 segments received
>     65043 segments send out
>     0 segments retransmited
>     18 bad segments received.

Is this it?  My counters show zero, in vastly more packets.

Andrew

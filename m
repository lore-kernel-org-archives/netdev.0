From: Andre Tomt <andre@tomt.net>
Subject: Re: Fw: 2.6.9 Oops in tcp_time_to_recover + 0x6d/0x1b0
Date: Thu, 28 Oct 2004 04:06:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41805418.9030209@tomt.net>
References: <20041026163802.6eefd7a6.akpm@osdl.org> <20041026164650.50bc2a9c.davem@davemloft.net> <417F158E.4010109@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <417F158E.4010109@tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andre Tomt wrote:
> David S. Miller wrote:
> 
>> Current BK should have a fix for this from Herbert Xu.
>>
> 
> is this what the
> 
> [TCP]: Handle real partial-ACKs of TSO frames correctly.
> [TCP]: Only re-set TSO size for packet which was TSO to begin with.
> [TCP]: Fix tcp_trim_head() calculations.
> 
> changesets fixed?

Sigh, I'm retarded. I was meaning to send this on-list, not off-list. 
Silly fingers.

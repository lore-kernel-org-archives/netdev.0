From: Andre Tomt <andre@tomt.net>
Subject: Re: FIB alternative fib_hash2.c
Date: Fri, 15 Apr 2005 19:31:00 +0200
Message-ID: <425FFA54.9070106@tomt.net>
References: <16991.54602.218744.163816@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16991.54602.218744.163816@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Hello!
> 
> Don't like to sit on this... originally an experiment to understand what we
> can expect from FIB lookup in the linux context. Beginning to think it 
> might be useful as is... memory is cheap. With full bgp and rDoS I see around
> double FIB lookup performance.  No-one has been brave enough to test it....
> Patch is for 2.6.11 and includes an Kconfig option different FIB alternatives.

Drool. Got some numbers? pps - flows - memory use, on what hardware, 
that sort of thing.

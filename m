From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Thu, 16 Dec 2004 17:02:59 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412161700590.532@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee>
 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
 <200412161302.42357.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Harald Welte <laforge@gnumonks.org>, Neil Horman <nhorman@redhat.com>,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200412161302.42357.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2004, Hasso Tepper wrote:

> No. There is only one primary address per interface and it is used if
> destination address doesn't indicate which source address to use.

In the linux world your first primary is used for this purpose if I am not 
mistaken.

But this shouldn't happen much in any sane network, and when it does it is 
not that unlikely the return traffic won't know how to reach you 
correctly..

Regards
Henrik

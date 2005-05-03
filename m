From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 3 May 2005 12:42:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.61.0505031239460.3205@netcore.fi>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl>
 <20050503092244.GA8864@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, "J. Simonetti" <jeroens@office.netland.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050503092244.GA8864@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005, Lennert Buytenhek wrote:
> (I know, "Every other router vendor out there does it this way."
> is not a good reason for doing it the same way.)

There's no specification requiring or recommending either of these 
approaches, either for v6 or v4 AFAICS so you can't depend on that 
behaviour..

Do you have specific data to back up "every other router vendor..." ? 
I doubt it's quite as uniform as that, but if so, it would certainly 
be a major motivation for a change.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] New version of net timestamp optimization
Date: 07 Apr 2004 08:24:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081340659.15893.117.camel@jzny.localdomain>
References: <20040406182941.7e759f4c.ak@suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040406182941.7e759f4c.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-04-06 at 12:29, Andi Kleen wrote:
> New version of the network packet timestamp optimization. Avoid calling gettimeofday
> in the network fast path when not needed.
> 

Andi,
The patch does look clean and attractive. I havent had time toi play
with it myself - but given the way gettimeofday has been torturing me
i will at some point. Also if you have time a 2.4.x patch would be
useful (wink, wink);->

cheers,
jamal

From: Peter Bieringer <pb@bieringer.de>
Subject: Re: netfilter6: REJECT target?
Date: Fri, 15 Aug 2003 19:05:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <96590000.1060967105@worker.muc.bieringer.de>
References: <Pine.LNX.4.44.0308132329050.15288-100000@netcore.fi>
 <20030813133440.23ad50d7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030813133440.23ad50d7.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Wednesday, August 13, 2003 01:34:40 PM -0700 "David S. Miller"
<davem@redhat.com> wrote:

> On Wed, 13 Aug 2003 23:30:49 +0300 (EEST)
> Pekka Savola <pekkas@netcore.fi> wrote:
> 
>> Is there some reason the IPv6 Netfilter REJECT target hasn't been merged 
>> during the last 2 years it has existed in Netfilter's patch-o-matic.
> 
> It might be more profitable to ask the netfilter lists
> than here.

>From some private correspondence some month ago my result is that I think
the netfilter6 team needs some more man-power. 

Currently I know only about Harald Welte, Andras Kis-Szabo has left the
team afair.

There are also some inconsistency in logging between IPv4 and IPv6
code...but looks like this is all low-prio ;-)

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/

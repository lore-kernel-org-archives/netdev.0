From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: don???t modify ip_summed; doing so
 treats packets with bad checksums as good.
Date: Fri, 13 May 2016 11:23:06 -0700
Message-ID: <57361B8A.70404@candelatech.com>
References: <57253527.7010009@candelatech.com> <20160501053059.GA26097@1wt.eu>
 <5736076F.10003@candelatech.com>
 <20160513.142121.1201664846732017162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, vijayp@vijayp.ca, tom@herbertland.com,
	ben@decadent.org.uk, sd@queasysnail.net,
	hannes@stressinduktion.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, akpm@linux-foundation.org,
	cwang@twopensource.com, netdev@vger.kernel.org, ej@evanjones.ca,
	nicolas.dichtel@6wind.com, phil@nwl.cc,
	makita.toshiaki@lab.ntt.co.jp, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160513.142121.1201664846732017162.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/13/2016 11:21 AM, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Fri, 13 May 2016 09:57:19 -0700
>
>> How do you feel about a new socket-option to allow a socket to
>> request the old veth behaviour?
>
> I depend upon the opinions of the experts who work upstream on and
> maintain these components, since it is an area I am not so familiar
> with.
>
> Generally speaking asking me directly for opinions on matters like
> this isn't the way to go, in fact I kind of find it irritating.  It
> can't all be on me.
>

Fair enough, thanks for your time.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 0/5] wireless: ti: Convert specialized logging macros to kernel style
Date: Thu, 31 Mar 2016 10:39:40 +0300
Message-ID: <87y48z3xkz.fsf@purkki.adurom.net>
References: <cover.1457395071.git.joe@perches.com>
	<87shz85gkq.fsf@purkki.adurom.net>
	<1459373791.25110.132.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459373791.25110.132.camel@perches.com> (Joe Perches's message
	of "Wed, 30 Mar 2016 14:36:31 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> On Wed, 2016-03-30 at 14:51 +0300, Kalle Valo wrote:
>> Joe Perches <joe@perches.com> writes:
>> > Using the normal kernel logging mechanisms makes this code
>> > a bit more like other wireless drivers.
>> Personally I don't see the point but I don't have any strong opinions. A
>> bigger problem is that TI drivers are not really in active development
>> and that's I'm not thrilled to take big patches like this for dormant
>> drivers.
>
> Not very dormant.
>
> 35 patches in the last year, most of them adding functionality.

Oh, I didn't realise it had that many patches. But the driver is
orphaned and doesn't have a maintainer so could I then have an ack from
one of the active contributors that this ok?

-- 
Kalle Valo

From: David Miller <davem@davemloft.net>
Subject: Re: missing in stable 4.1.1 - was Re: pull-request: can 2015-06-21
Date: Tue, 30 Jun 2015 14:20:55 -0700 (PDT)
Message-ID: <20150630.142055.2284481896639682516.davem@davemloft.net>
References: <1434906299-19452-1-git-send-email-mkl@pengutronix.de>
	<20150623.064338.1193972764545855895.davem@davemloft.net>
	<5592EE98.8030705@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, gregkh@linuxfoundation.org,
	mkl@pengutronix.de, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, kernel@pengutronix.de
To: socketcan@hartkopp.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5592EE98.8030705@hartkopp.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 30 Jun 2015 21:31:36 +0200

> Hello Greg,
> 
> On 23.06.2015 15:43, David Miller wrote:
>> From: Marc Kleine-Budde <mkl@pengutronix.de>
>> Date: Sun, 21 Jun 2015 19:04:58 +0200
>>
>>> this is a, probably too late, pull request for v4.1.
>>>
>>> Oliver Hartkopp fixed a bug in the generic CAN frame handling code,
>>> which may
>>> lead to loss of CAN frames. It was introduced during v4.1 development.
>>>
>>> Please queue via net/master if possible, net-next/master
>>> otherwise. I've added
>>> stable on Cc, just in case.
>>
>> Pulled, thanks.
> 
> the patch "can: fix loss of CAN frames in raw_rcv" was sent to stable
> on 2015-06-21 but unfortunately did not find its way into 4.1.1 :-(
> 
> The upstream commit is:
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=36c01245eb8046c16eee6431e7dbfbb302635fa8
> 
> which slipped into 4.2 at merge window opening time.
> 
> So it just got lost in the stable queue somehow.

Please take care of CAN -stable submissions yourself, thanks.

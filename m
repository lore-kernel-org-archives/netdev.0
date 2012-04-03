From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: fix sparse warning for cgw_list
Date: Tue, 03 Apr 2012 18:00:43 +0200
Message-ID: <4F7B1EAB.6060504@hartkopp.net>
References: <1332716750-3455-1-git-send-email-dbaluta@ixiacom.com> <4F702679.3090302@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dbaluta@ixiacom.com, davem@davemloft.net,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Baluta <daniel.baluta@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F702679.3090302@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26.03.2012 10:19, Marc Kleine-Budde wrote:

> On 03/26/2012 01:05 AM, dbaluta@ixiacom.com wrote:
>> From: Daniel Baluta <daniel.baluta@gmail.com>
>>
>> Make cgw_list static to remove the following sparse warning:
>> net/can/gw.c:69:1: warning: symbol 'cgw_list' was not declared.
>> Should it be static?
>>
>> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> 
> Thanks, applied to can-next.
> 


Hi Marc,

it looks like that this patch is still sitting in can-next.

What about a pull request for Daves net-tree for 3.4-rc1 ?

Regards,
Oliver

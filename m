From: Wolfgang Zarre <lkdev@essax.com>
Subject: Re: [PATCH wg-linux-can-next devel 1/1] can: cc770: Fix indirect
 access deadlock on ISA cards
Date: Tue, 17 Jan 2012 13:10:34 +0100
Message-ID: <4F15653A.2050904@essax.com>
References: <1326630094-3126-1-git-send-email-lkdev@essax.com> <4F13ED60.5070602@grandegger.com>
Reply-To: lkdev@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	socketcan-users@lists.berlios.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F13ED60.5070602@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Wolfgang,

> On 01/15/2012 01:21 PM, Wolfgang Zarre wrote:
>> This fix avoids a deadlock if an interrupt occurs
>> during consecutive port operations on ISA cards
>> utilising indirect access via address and data
>> port.
>>
>> Tested on a B&R ISA card.
>>
>> CC: linux-can@vger.kernel.org
>> CC: netdev@vger.kernel.org
>> Signed-off-by: Wolfgang Zarre<lkdev@essax.com>
>
> Acked-by: Wolfgang Grandegger<wg@grandegger.com>

Thanks.

>
> Next time, please drop the CC to the old BerliOS Socketcan mailing
> lists. Marc, Oliver? Do we, should we, still send patches to the
> "netdev@vger.kernel.org" as well.

Hmmm, actually I dropped to the old BerliOS Socketcan mailing list but
not as CC statement in the email body , however, please let me know
if You prefer to have it there included as well.

Thanks.

>
> Wolfgang.

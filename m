From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [net-next v2 56/71] macb: Move the Atmel driver
Date: Wed, 03 Aug 2011 09:50:21 +0100
Message-ID: <4E390BCD.4010609@atmel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com> <1312082850-24914-57-git-send-email-jeffrey.t.kirsher@intel.com> <4E36BCEF.8080703@atmel.com> <1312351168.2294.92.camel@jtkirshe-mobl> <20110803084719.GA2607@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Jamie Iles <jamie@jamieiles.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:19570 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab1HCIuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 04:50:35 -0400
In-Reply-To: <20110803084719.GA2607@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2011 09:47 AM, Jamie Iles wrote:
> On Tue, Aug 02, 2011 at 10:59:28PM -0700, Jeff Kirsher wrote:
>> On Mon, 2011-08-01 at 07:49 -0700, Nicolas Ferre wrote:
>>> On 07/31/2011 04:27 AM, Jeff Kirsher wrote:
>>>> Move the Atmel driver into drivers/net/ethernet/cadence/ and
>>>> make the necessary Kconfig and Makefile changes.
>>>>
>>>> CC: Nicolas Ferre<nicolas.ferre@atmel.com>
>>>
>>> You can add my:
>>> Acked-by: Nicolas Ferre<nicolas.ferre@atmel.com>
>>>
>>>> CC: Jamie Iles<jamie@jamieiles.com>
>>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>
>> Nicolas/Jamie-
>>
>> I have a v3 series of patches coming out here imminently, and I have
>> tweaked the Kconfig just a bit based on feedback from others.  Since the
>> "tweak" made sense for all the Kconfig, I applied it across the board.
>> Here is the new Kconfig:
> [...]
>> If these changes are fine, I can add your ACK's.
>
> It all reads fine to me though I wonder if we should substitute Atmel
> for Cadence.  Perhaps this should be a separate patch though that makes
> it a little clearer in the drivers too.

Yes, that is true.

> Anyhow, for now I'm happy as it is, so:
>
> Acked-by: Jamie Iles<jamie@jamieiles.com>

Yes, you can add my:

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
-- 
Nicolas Ferre

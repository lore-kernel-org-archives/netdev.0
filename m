From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Sat, 13 Jun 2009 08:39:39 -0400
Message-ID: <9e4733910906130539k4af2dde3k1fe85e8932ef563e@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	 <9e4733910906122021k4568df6rd80fb915b64ac12@mail.gmail.com>
	 <6097c490906122237l2be1836dsd30c3160f1a15ae8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: maxim@mox.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:1833 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZFMMji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 08:39:38 -0400
In-Reply-To: <6097c490906122237l2be1836dsd30c3160f1a15ae8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 13, 2009 at 1:37 AM, Maxim Osipov<maxim.osipov@gmail.com> wrote:
> On Sat, Jun 13, 2009 at 7:21 AM, Jon Smirl<jonsmirl@gmail.com> wrote:
>> On Mon, Jun 1, 2009 at 10:54 AM, Dmitry
>> Eremin-Solenikov<dbaryshkov@gmail.com> wrote:
>>> Hi,
>>>
>>> As a part of research activities the Embedded Systems - Open Platform Group
>>> from Siemens Corporate Technology we are working on adding support for
>>> the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our current
>>> implementation is neither certified nor even feature complete. However
>>> we'd like to present current state of our patchset to the Linux developers
>>> community to gain comments, fixes, ideas, etc. This is not yet a pull request,
>>> but more like an RFC.
>>>
>>
>> The Zigbee alliance requires a minimum of $3,500/yr from any company
>> making a product based on the spec. How are you going to reconcile
>> this requirement with the GPL? They exempt non-commercial users but
>> the GPL doesn't allow code to be free for one purpose and pay for
>> another.
>>
>
> For now, we do not release any ZigBee implementation. BTW - could you
> refer to particular clause of GPL, which doesn't allow user to pay for
> code?

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

You can charge a duplication fee when you do the copying. It is fine
to charge for things like support or the hardware that comes with the
software.


>
> Regards,
> Maxim
>



-- 
Jon Smirl
jonsmirl@gmail.com

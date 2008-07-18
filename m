From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Fri, 18 Jul 2008 08:40:10 -0500
Message-ID: <E7FD62BF-C2BB-4803-87AB-91DD7AB8FD0C@kernel.crashing.org>
References: <200805261152.37636.laurentp@cse-semaphore.com>
	<200806261321.24338.laurentp@cse-semaphore.com>
	<20080626175523.54728d07@vitb.ru.mvista.com>
	<200807181126.48246.laurentp@cse-semaphore.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200807181126.48246.laurentp@cse-semaphore.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jul 18, 2008, at 4:26 AM, Laurent Pinchart wrote:

> On Thursday 26 June 2008, Vitaly Bordug wrote:
>> On Thu, 26 Jun 2008 13:21:23 +0200
>> Laurent Pinchart <laurentp@cse-semaphore.com> wrote:
>>
>>>> There should be no dependencies. When the OF GPIO support is not
>>>> selected linux/of_gpio.h will define of_get_gpio() as a stub, so  
>>>> the
>>>> fs_enet driver will fall back to the legacy binding.
>>>
>>> Have we reached a consensus on which tree the patch should go to ?
>> I think it should go through powerpc tree, not seeing too much
>> netdev-generic stuff in here. If noone will object, Kumar will pick  
>> it up I
>> guess...
>
> Kumar, could you pick it up ? I'd like to see this in 2.6.27.
>
> Best regards,

Jeff said he applied both to his tree already.

- k

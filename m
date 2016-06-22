From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: [PATCH v2 2/3] mwifiex: move .get_tx_power logic to station ioctl
 file
Date: Wed, 22 Jun 2016 08:57:07 -0400
Message-ID: <92112c3f-0016-87f4-c071-42485772e1fa@osg.samsung.com>
References: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
 <1465232558-31678-3-git-send-email-javier@osg.samsung.com>
 <87wplxdsln.fsf@kamboji.qca.qualcomm.com>
 <12ccd90e-e3eb-ecac-b23f-8124b0db32ad@osg.samsung.com>
 <2b5e5833ecc74a2b9cd822e8455cd0af@SC-EXCH04.marvell.com>
 <8dc6e64a-3429-4bed-e5c9-da6880eb9505@osg.samsung.com>
 <87shwkes65.fsf@kamboji.qca.qualcomm.com>
 <aeeb25f2-3253-0931-1e84-edc4590208b3@osg.samsung.com>
 <87vb11iw7q.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Julian Calaby <julian.calaby@gmail.com>,
	Shengzhen Li <szli@marvell.com>,
	Enric Balletbo i Serra <enric.balletbo@collabora.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Nishant Sarmukadam <nishants@marvell.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:49439 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbcFVNDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 09:03:36 -0400
In-Reply-To: <87vb11iw7q.fsf@purkki.adurom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Kalle,

On 06/22/2016 02:17 AM, Kalle Valo wrote:
> Javier Martinez Canillas <javier@osg.samsung.com> writes:
> 
>>>> Patch 3/3 applies cleanly even after dropping patch 2/3.
>>>> Is that Ok for you or do you want me to re-resend a v3
>>>> with only patches 1/3 and 3/3?
>>>
>>> I can drop patch 2, no need to resend. Thanks.
>>>
>>
>> I saw that you sent your pull request for v4.8 but the
>> patches from this series were not included:
>>
>> https://lkml.org/lkml/2016/6/21/400
> 
> I had forgotten to change the state of patches 1 and 3 from 'Changes
> Requested' back to 'New' and that's why I missed them. I did that now so
> they are back in my queue:
> 
> https://patchwork.kernel.org/patch/9158855/
> https://patchwork.kernel.org/patch/9158851/
> 
> Thanks for checking.
> 

Ok, thanks for the information.

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America

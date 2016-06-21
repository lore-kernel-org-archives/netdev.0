From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: [PATCH v2 2/3] mwifiex: move .get_tx_power logic to station ioctl
 file
Date: Tue, 21 Jun 2016 10:47:01 -0400
Message-ID: <aeeb25f2-3253-0931-1e84-edc4590208b3@osg.samsung.com>
References: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
 <1465232558-31678-3-git-send-email-javier@osg.samsung.com>
 <87wplxdsln.fsf@kamboji.qca.qualcomm.com>
 <12ccd90e-e3eb-ecac-b23f-8124b0db32ad@osg.samsung.com>
 <2b5e5833ecc74a2b9cd822e8455cd0af@SC-EXCH04.marvell.com>
 <8dc6e64a-3429-4bed-e5c9-da6880eb9505@osg.samsung.com>
 <87shwkes65.fsf@kamboji.qca.qualcomm.com>
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
Received: from lists.s-osg.org ([54.187.51.154]:32842 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488AbcFUOrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 10:47:10 -0400
In-Reply-To: <87shwkes65.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Kalle,

On 06/10/2016 03:54 PM, Kalle Valo wrote:
> Javier Martinez Canillas <javier@osg.samsung.com> writes:
> 
>>> This patch (2/3) is only for code rearrangement and adds an
>>> unnecessary wrapper function. We can simply drop the patch.
>>
>> Agreed.
>>
>> Kalle,
>>
>> Patch 3/3 applies cleanly even after dropping patch 2/3.
>> Is that Ok for you or do you want me to re-resend a v3
>> with only patches 1/3 and 3/3?
> 
> I can drop patch 2, no need to resend. Thanks.
> 

I saw that you sent your pull request for v4.8 but the
patches from this series were not included:

https://lkml.org/lkml/2016/6/21/400

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America

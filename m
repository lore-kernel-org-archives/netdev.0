From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/3] stmmac: change dma descriptors to __le32
Date: Fri, 29 Jul 2016 10:26:24 +0200
Message-ID: <9d83a435-eff1-a2d3-0d3d-158503564425@st.com>
References: <20160721182329.13478-1-michael.weiser@gmx.de>
 <20160721182329.13478-3-michael.weiser@gmx.de>
 <e5229894-45fc-671e-641a-e41c7ab176d7@st.com>
 <20160729075343.GD415@weiser.dinsnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	<netdev@vger.kernel.org>
To: Michael Weiser <michael.weiser@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:16247 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269AbcG2I04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 04:26:56 -0400
In-Reply-To: <20160729075343.GD415@weiser.dinsnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/2016 9:53 AM, Michael Weiser wrote:
> Hi Giuseppe,
>
> On Tue, Jul 26, 2016 at 02:13:45PM +0200, Giuseppe CAVALLARO wrote:
>
>>> -			ep++;
>>> +			ep++);
>> there is a build problem here.
>> Pls fix it.
>
> Thanks for your review. I've got it fixed locally. An updated patchset
> will be forthcoming as soon as I've sorted a problem with sun4i-emac
> which I've been asked to look into as well.
>

ok, as you send the new version I will do a run on ARM box based too

peppe

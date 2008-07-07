From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 00/06]: VLAN TCI truncation fixes
Date: Mon, 7 Jul 2008 14:16:13 -0700
Message-ID: <9929d2390807071416g1f688affg37230dfd2786bac@mail.gmail.com>
References: <48714BA3.3080102@trash.net> <4871769E.2020305@garzik.org>
	 <48717B49.1060804@trash.net>
	 <20080706.204902.245651270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jeff@garzik.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, ionut@cs.columbia.edu,
	baum@tehutinetworks.net, andy@greyhouse.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:53847 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710AbYGGVQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:16:15 -0400
Received: by yx-out-2324.google.com with SMTP id 8so518363yxm.1
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2008 14:16:14 -0700 (PDT)
In-Reply-To: <20080706.204902.245651270.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 6, 2008 at 8:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 07 Jul 2008 04:11:21 +0200
>
>> Jeff Garzik wrote:
>> > Patrick McHardy wrote:
>> >>      e1000: don't truncate VLAN TCI with VLAN stripping
>> >>      e1000e: don't truncate VLAN TCI with VLAN stripping
>> >>      igb: don't truncate VLAN TCI with VLAN stripping
>> >>      ixgb: don't truncate VLAN TCI with VLAN stripping
>> >>      starfire: don't truncate VLAN TCI with VLAN stripping
>> >>      tehuti: don't truncate VLAN TCI with VLAN stripping
>> >
>> > Acked-by: Jeff Garzik <jgarzik@redhat.com>
>> Thanks.
>> >
>> > Though I would suggest combining all these patches into a single
>> > patch, since they constitute a single logical change, and each change
>> > is self-contained and small.
>>
>> Attached is a combined patch with these 6 patches.
>
> Applied, thanks everyone.
>

Although it appears to be to late, since Dave has already pulled these in.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff

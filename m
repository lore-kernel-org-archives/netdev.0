From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: correct the parameter description
Date: Thu, 24 Sep 2009 12:08:50 -0700
Message-ID: <9929d2390909241208m51077fafpd6d72f3b5b109a97@mail.gmail.com>
References: <20090924143627.GD2919@psychotron.redhat.com>
	 <1253816772.3153.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jpirko@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:56651 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbZIXTIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 15:08:46 -0400
Received: by pxi27 with SMTP id 27so2036037pxi.22
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2009 12:08:50 -0700 (PDT)
In-Reply-To: <1253816772.3153.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2009 at 11:26, Peter P Waskiewicz Jr
<peter.p.waskiewicz.jr@intel.com> wrote:
> On Thu, 2009-09-24 at 07:36 -0700, Jiri Pirko wrote:
>> ccffad25b5136958d4769ed6de5e87992dd9c65c changed parameters for function
>> ixgbe_update_uc_addr_list_generic but parameter description was not updated.
>> This patch corrects it.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
> Thanks Jiri,
>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>

Jiri/Dave-

I already have a few ixgbe patches in my queue, so I will add this
patch to my queue and push it along with my other patches to
Dave/netdev.

-- 
Cheers,
Jeff

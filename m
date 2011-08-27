From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Unicast hash for IXGBEVF driver
Date: Sat, 27 Aug 2011 00:34:49 -0700
Message-ID: <CAL3LdT6UBxEgjEX0MMCRmnXw2243nq5GyvYtQ9JOdGRtnsHS6g@mail.gmail.com>
References: <4E589B69.7020305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net
To: "J.Hwan Kim" <frog1120@gmail.com>,
	Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64496 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab1H0Heu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2011 03:34:50 -0400
Received: by fxh19 with SMTP id 19so3087973fxh.19
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2011 00:34:49 -0700 (PDT)
In-Reply-To: <4E589B69.7020305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 27, 2011 at 00:23, J.Hwan Kim <frog1120@gmail.com> wrote:
> Hi, everyone
>
> How can I distribute the packets according to destination MAC address
> into multi-virtual fucntion queue?
> Now, my setting is that all bit of PFUTA are '1' and ROPE bit is 1,
> so all mac packet is duplicated to all VF queue.
> I cannot understand the meaning of bits of PFUTA and the relation
> with mac address.
> I want to distribute the received packets to RX queues respectively,
> not duplicated.
>
>
> Thanks in advance.
>
> Best Regards,
> J.Hwan Kim
>

Adding Greg Rose, since he is the ixgbevf driver maintainer.  He
should be able to answer your questions early next week, unless he is
checking his email over the weekend.

-- 
Cheers,
Jeff

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3] driver/net/*: remove redundant argument comments
Date: Sat, 22 Nov 2008 00:10:03 -0800
Message-ID: <9929d2390811220010q5a064ccblc182ce0128250da6@mail.gmail.com>
References: <4927b790.0e0d6e0a.65cc.ffffcb05@mx.google.com>
	 <9929d2390811212355j635e0e8iee0e53678efc5f09@mail.gmail.com>
	 <20081121.235656.193713995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: qhfeng.kernel@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:1430 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbYKVIKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 03:10:04 -0500
Received: by yw-out-2324.google.com with SMTP id 9so571031ywe.1
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2008 00:10:03 -0800 (PST)
In-Reply-To: <20081121.235656.193713995.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 11:56 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> Date: Fri, 21 Nov 2008 23:55:27 -0800
>
>> I would agree that "@rx_ring: pointer to receive ring structure" is
>> probably not the best documentation, but rather than removing it, I
>> would suggest improving it.
>
> Jeff, he's removing it because the function no longer takes
> that argument any more.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

I apologize, based on the patch comment of "remove redundant argument
comments" I took that he was removing comments that were "unnecessary
and repetitive" and not referring to "non-existent arguments".

I rescind my Nak.

-- 
Cheers,
Jeff

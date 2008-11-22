From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] network devices generating uevents?
Date: Fri, 21 Nov 2008 23:35:47 -0800
Message-ID: <9929d2390811212335j77a580a5k9c954741054c21e0@mail.gmail.com>
References: <20081121134659.5b305b5c@extreme>
	 <20081121.172433.65626835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:47130 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbYKVHfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:35:48 -0500
Received: by yx-out-2324.google.com with SMTP id 8so567840yxm.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 23:35:47 -0800 (PST)
In-Reply-To: <20081121.172433.65626835.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 5:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 21 Nov 2008 13:46:59 -0800
>
>> Perhaps the following would make it easier for applications to
>> track network device events without having to use netlink.
>> Compile tested only so far. The implementation is almost trivial...
>
> I'm fine with this, what do others think?
> --

Looks fine to me, thanks to Stephen for taking my suggestion and
running with it.

-- 
Cheers,
Jeff

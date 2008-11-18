From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Mon, 17 Nov 2008 17:43:05 -0800
Message-ID: <9929d2390811171743v6dbe7a52w55f3ba4a95de6136@mail.gmail.com>
References: <20081117234207.854110282@vyatta.com>
	 <9929d2390811171727m14571c8bg64909d346a3753a0@mail.gmail.com>
	 <20081117173558.7d861bcf@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:45702 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbYKRBnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 20:43:06 -0500
Received: by rn-out-0910.google.com with SMTP id k40so2266666rnd.17
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 17:43:05 -0800 (PST)
In-Reply-To: <20081117173558.7d861bcf@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2008 at 5:35 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 17 Nov 2008 17:27:05 -0800
> "Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote:
>
>> On Mon, Nov 17, 2008 at 3:42 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>> > This sequence of patches breaks the network device adminstration
>> > function table away from the network device data structure. It is
>> > a transitional API change (both keep working), and this set of patches
>> > hits a range of commonly used drivers. This should be enough to make sure
>> > both old and new interfaces get used and tested.
>> >
>> > --
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >
>>
>> Did I miss a patch, or did you intentionally not convert ixgbe?
>
> Since it was so similar to ixgb, both files are patched in same patch bundle.

Got it, thanks.

-- 
Cheers,
Jeff

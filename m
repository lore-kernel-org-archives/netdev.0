From: Ani Sinha <ani@arista.com>
Subject: Re: iproute2 compatibility
Date: Thu, 1 Oct 2015 14:30:01 -0700
Message-ID: <CAOxq_8MspU9sdws-5LKKFSdS9M0roM1ULBcWW=BdgTQTOkQDGQ@mail.gmail.com>
References: <CAOxq_8MPyWbPLeNWyEiSwq9xXgHwSXm29T3849HLmOg3Z7TXuw@mail.gmail.com>
 <1443732504.32531.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36586 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbbJAVaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 17:30:22 -0400
Received: by igcrk20 with SMTP id rk20so4566181igc.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 14:30:21 -0700 (PDT)
In-Reply-To: <1443732504.32531.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 1:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-10-01 at 13:06 -0700, Ani Sinha wrote:
>> Hi Stephen :
>>
>> I was looking around but could not find clear evidence that a later
>> version of iproute2 is compatible with an older kernel. Specifically,
>> we are wondering if iproute2 v 3.6 is compatible with linux kernel
>> 3.4. Highly appreciate any pointers on this.
>
> We try hard to keep iproute2 compatible with all kernels.
>

Thanks!

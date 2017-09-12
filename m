From: Ben Greear <greearb@candelatech.com>
Subject: Re: Can libpcap filter on vlan tags when vlans are
 hardware-accelerated?
Date: Tue, 12 Sep 2017 11:56:49 -0700
Message-ID: <c4e37428-562e-a41d-56e4-4c1ed24cc127@candelatech.com>
References: <51a124d5-8a5f-35d4-5242-fd8a289f50b5@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34230 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbdILS4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 14:56:50 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 1F1BA40A5CB
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 11:56:50 -0700 (PDT)
In-Reply-To: <51a124d5-8a5f-35d4-5242-fd8a289f50b5@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2017 11:54 AM, Ben Greear wrote:
> It does not appear to work on Fedora-26, and I'm curious if someone knows what needs
> doing to get this support working?
>
> Thanks,
> Ben
>


Gah, I spoke too soon.  system-test guy says it works on cmd-line, but
not when we try to make it work in another way...could be local bug,
I'll poke at this more.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

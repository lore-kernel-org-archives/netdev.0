From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v3 net-next 00/10] openvswitch: Conntrack integration improvements.
Date: Thu, 9 Feb 2017 11:24:56 -0800
Message-ID: <44856463-0FB9-4C62-8EF2-43ABAA2447ED@ovn.org>
References: <1486603837-7202-1-git-send-email-jarno@ovn.org> <CAOrHB_CiVOAQzBpFccZrnuS2Aa2YpdjnGeoivahy+MCdjuw1cQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, David Miller <davem@davemloft.net>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35606 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdBIUbJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 15:31:09 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so1163685pge.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 12:31:08 -0800 (PST)
In-Reply-To: <CAOrHB_CiVOAQzBpFccZrnuS2Aa2YpdjnGeoivahy+MCdjuw1cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 9, 2017, at 8:44 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Wed, Feb 8, 2017 at 5:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> This series improves the conntrack integration code in the openvswitch
>> module by fixing outdated comments (patch 1), bugs (patches 2, 3, and
>> 7), clarifying code (patches 4, 5, and 6), improving performance
>> (patch 10), and adding new features enabling better translation from
>> firewall admission policy to network configuration requested by user
>> communities (patches 8 and 9).
>> 
>> v3: Rebase to the current net-next, add the comment only changing
>>    patch 1 and reshuffle some of the patches as requested by Joe.
>> 
> 
> All patches looks good to me.
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> 
> Thanks.

Thanks for the review!

Joe spotted some english language and coding style issues I had not addressed in v3, so I just posted a v4. I included Joes and yours Acks, but not sure if that is the proper protocol, or if you need to Ack the v4 again. Sorry for the inconvenience!

  Jarno

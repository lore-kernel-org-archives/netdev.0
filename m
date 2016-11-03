From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] rtl8xxxu: Fix for authentication failure
Date: Thu, 3 Nov 2016 10:39:14 -0500
Message-ID: <6879f303-7cdc-6e0a-3943-44b541971b7d@lwfinger.net>
References: <cover.1477769750.git.john@zgus.com> <20161030102046.GA5784@cube>
 <8dba6346-332e-84e6-89b2-02033a449f25@lwfinger.net>
 <CAAye0QNZYjg1NDmXmjMXNJqa7nsbvfgoX8et1g1+HT2S2O=L1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Heenan <john@zgus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34697 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753398AbcKCPjR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 11:39:17 -0400
In-Reply-To: <CAAye0QNZYjg1NDmXmjMXNJqa7nsbvfgoX8et1g1+HT2S2O=L1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2016 02:10 AM, John Heenan wrote:
> On 3 November 2016 at 11:00, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>> On 10/30/2016 05:20 AM, John Heenan wrote:
>>>
>>> This fix enables the same sequence of init behaviour as the alternative
>>> working driver for the wireless rtl8723bu IC at
>>> https://github.com/lwfinger/rtl8723bu
>>>
>>> For exampe rtl8xxxu_init_device is now called each time
>>> userspace wpa_supplicant is executed instead of just once when
>>> modprobe is executed.
>>
>>
>> After all the trouble you have had with your patches, I would expect you to
>> use more care when composing the commit message. Note the typo in the
>> paragraph above.
>>
>
> OK, the nasty games continue and the message is not getting through.
>
> An appropriate response by a maintainer would have been to request I
> revise the code according to the way it has currently and elegantly
> revised in.

I am NOT a maintainer for this driver. I do have an interest in it, but not in 
any official capacity.

If you cannot accept constructive criticism, you are in the wrong activity. 
Please grow up!

Larry

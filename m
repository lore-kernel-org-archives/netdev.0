From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers 2016-11-29
Date: Thu, 01 Dec 2016 07:19:19 +0200
Message-ID: <87vav4rzu0.fsf@kamboji.qca.qualcomm.com>
References: <87r35utjq7.fsf@kamboji.qca.qualcomm.com>
        <20161130.143444.242053190479060640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130.143444.242053190479060640.davem@davemloft.net> (David
        Miller's message of "Wed, 30 Nov 2016 14:34:44 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Tue, 29 Nov 2016 16:59:44 +0200
>
>> if there's still time here's one more patch to 3.9. I think this is good
>> to have in 3.9 as it fixes an issue where we were printing uninitialised
>> memory in mwifiex. I had this in wireless-drivers already for some time
>> as I was waiting for other fixes and nothing serious actually came up.
>> 
>> If this doesn't make it to 3.9 that's not a problem, I'll just merge
>> this to wireless-drivers-next. Let me know what you prefer.
>
> Unless you are in a time-machine of some sort I assume you mean "4.9" not
> "3.9" :-)
>
> Pulled, thanks.

Hah, I have no idea where I came up with this "3.9" :) I was trying mean
"4.9" of course, thanks for pulling.

-- 
Kalle Valo

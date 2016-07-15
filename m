From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2016-07-13
Date: Fri, 15 Jul 2016 10:22:28 +0300
Message-ID: <87bn1zxt57.fsf@kamboji.qca.qualcomm.com>
References: <87a8hlz91i.fsf@kamboji.qca.qualcomm.com>
	<20160714.174155.39693398036427861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160714.174155.39693398036427861.davem@davemloft.net> (David
	Miller's message of "Thu, 14 Jul 2016 17:41:55 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Wed, 13 Jul 2016 21:29:13 +0300
>
>> here's a pull request for net-next. This time there are few conflicts
>> due to the cfg80211 scan API changes, and one of them is easy to miss,
>> so please pay extra attention to them. Otherwise there's not nothing
>> really out of ordinary. Please note that I also pulled wireless-drivers
>> to wireless-drivers-next to reduce the amount of conflicts.
>> 
>> So about the conflicts, the obvious are notified by git:
>  ...
>> I have attached the output from git diff as an example how to resolve
>> this, hopefully that helps. Please let me know if there are any problems
>> or if you want to handle these differently.
>
> Thanks for all of the conflict resolution info, it really helped.
>
> I pushed this all out, please double check my work.

Looks good, thanks!

-- 
Kalle Valo

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2017-04-03
Date: Tue, 04 Apr 2017 20:48:35 +0300
Message-ID: <87r318jc7g.fsf@kamboji.qca.qualcomm.com>
References: <87a87xohpp.fsf@kamboji.qca.qualcomm.com>
        <20170404.103144.1438343234401389523.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38936 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932191AbdDDRsn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:48:43 -0400
In-Reply-To: <20170404.103144.1438343234401389523.davem@davemloft.net> (David
        Miller's message of "Tue, 04 Apr 2017 10:31:44 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Mon, 03 Apr 2017 14:26:10 +0300
>
>> here few really small fixes. I'm hoping this to be the last pull request
>> for 4.11.
>> 
>> Please let me if there are any problems.
>
> Pulled, thanks.
>
> But I will warn you, you say fixes, but your Subject line and
> GIT tag says "-next" so I pulled it into net-next.

Sorry, I used the wrong pull request template and that's why I had the
wrong subject in this pull request. So actually this was supposed to be
for net, not net-next. Any chance you could also pull this to net so
that we can still get the fixes to 4.11?

My tree setup is like this:

wireless-drivers -> net
wireless-drivers-next -> net-next

-- 
Kalle Valo

From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2016-07-13
Date: Thu, 14 Jul 2016 17:41:55 -0700 (PDT)
Message-ID: <20160714.174155.39693398036427861.davem@davemloft.net>
References: <87a8hlz91i.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a8hlz91i.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo@codeaurora.org>
Date: Wed, 13 Jul 2016 21:29:13 +0300

> here's a pull request for net-next. This time there are few conflicts
> due to the cfg80211 scan API changes, and one of them is easy to miss,
> so please pay extra attention to them. Otherwise there's not nothing
> really out of ordinary. Please note that I also pulled wireless-drivers
> to wireless-drivers-next to reduce the amount of conflicts.
> 
> So about the conflicts, the obvious are notified by git:
 ...
> I have attached the output from git diff as an example how to resolve
> this, hopefully that helps. Please let me know if there are any problems
> or if you want to handle these differently.

Thanks for all of the conflict resolution info, it really helped.

I pushed this all out, please double check my work.

Thanks.

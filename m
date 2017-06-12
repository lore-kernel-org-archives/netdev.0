From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2017-06-12
Date: Mon, 12 Jun 2017 10:15:51 -0400 (EDT)
Message-ID: <20170612.101551.1401883231011186549.davem@davemloft.net>
References: <87poe98h90.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87poe98h90.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo@codeaurora.org>
Date: Mon, 12 Jun 2017 16:31:23 +0300

> here's a pull request to net-next, more info in the tag below. But do
> note that Stephen reported qtnfmac will fail to build with the net tree
> due to the changes in netdev destructor:
> 
> https://lkml.kernel.org/r/20170608122759.7ffda0c3@canb.auug.org.au
> 
> So once you pull these changes AND your net tree to net-next you need to
> apply Stephen's patch above. As of this writing there is no build
> breakage (yet).
> 
> Please let me know if there are any problems.

Yep, I'll have to deal with that in the merge commit next time I pull
net into net-next, thanks for reminding me.

Pulled, thanks.

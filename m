From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath: change logging functions to return void
Date: Tue, 23 Sep 2014 18:17:25 +0300
Message-ID: <878ulacqnu.fsf@kamboji.qca.qualcomm.com>
References: <1411407334.2952.46.camel@joe-AO725>
	<874mvzj7bu.fsf@kamboji.qca.qualcomm.com>
	<20140923144627.GG23806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Joe Perches <joe@perches.com>,
	Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	<ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	wil6210 <wil6210@qca.qualcomm.com>, <ath6kl@lists.infradead.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140923144627.GG23806@tuxdriver.com> (John W. Linville's
	message of "Tue, 23 Sep 2014 10:46:27 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"John W. Linville" <linville@tuxdriver.com> writes:

> On Tue, Sep 23, 2014 at 07:20:53AM +0300, Kalle Valo wrote:
>> Joe Perches <joe@perches.com> writes:
>> 
>> >  drivers/net/wireless/ath/wil6210/debug.c   | 14 ++++----------
>> >  drivers/net/wireless/ath/wil6210/wil6210.h |  7 +++++--
>> >  7 files changed, 32 insertions(+), 56 deletions(-)
>> 
>> John, as this patch also contains a wil6210 change how do you want to
>> handle this?
>
> I had presumed that you would merge it through the ath tree, so I
> deleted it...

That's a clear case then, I'll take it :)

-- 
Kalle Valo

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/2] net-ath9k_htc: Replace a variable initialisation by an assignment in ath9k_htc_set_channel()
Date: Fri, 15 Apr 2016 15:09:23 +0300
Message-ID: <87ega7qdjg.fsf@kamboji.qca.qualcomm.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<5686C390.5060600@users.sourceforge.net>
	<5686C47E.1040906@users.sourceforge.net>
	<CAGRGNgXR_OoER0rN5Z8n_5VtZimpU7WDNZuc4vkdb2eKDT2frQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ath9k-devel@lists.ath9k.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	SF Markus Elfring <elfring@users.sourceforge.net>,
	kernel-janitors <kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGRGNgXR_OoER0rN5Z8n_5VtZimpU7WDNZuc4vkdb2eKDT2frQ@mail.gmail.com>
	(Julian Calaby's message of "Fri, 8 Apr 2016 11:40:45 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Calaby <julian.calaby@gmail.com> writes:

> Hi Kalle,
>
> On Sat, Jan 2, 2016 at 5:25 AM, SF Markus Elfring
> <elfring@users.sourceforge.net> wrote:
>> From: Markus Elfring <elfring@users.sourceforge.net>
>> Date: Fri, 1 Jan 2016 19:09:32 +0100
>>
>> Replace an explicit initialisation for one local variable at the beginning
>> by a conditional assignment.
>>
>> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
>
> This looks sane to me.
>
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Before I commit I'll just change the commit title to:

ath9k_htc: Replace a variable initialisation by an assignment in ath9k_htc_set_channel()

-- 
Kalle Valo

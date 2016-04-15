From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/2] net-ath9k_htc: Replace a variable initialisation by
 an assignment in ath9k_htc_set_channel()
Date: Sat, 16 Apr 2016 00:34:25 +1000
Message-ID: <CAGRGNgUWZobf1-xiSfPVxBxktEW1Zh37bGEdpNte1rUdVeNOdg@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net> <5686C390.5060600@users.sourceforge.net>
 <5686C47E.1040906@users.sourceforge.net> <CAGRGNgXR_OoER0rN5Z8n_5VtZimpU7WDNZuc4vkdb2eKDT2frQ@mail.gmail.com>
 <87ega7qdjg.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ath9k-devel@lists.ath9k.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	SF Markus Elfring <elfring@users.sourceforge.net>,
	kernel-janitors <kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ega7qdjg.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

On Fri, Apr 15, 2016 at 10:09 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Julian Calaby <julian.calaby@gmail.com> writes:
>
>> Hi Kalle,
>>
>> On Sat, Jan 2, 2016 at 5:25 AM, SF Markus Elfring
>> <elfring@users.sourceforge.net> wrote:
>>> From: Markus Elfring <elfring@users.sourceforge.net>
>>> Date: Fri, 1 Jan 2016 19:09:32 +0100
>>>
>>> Replace an explicit initialisation for one local variable at the beginning
>>> by a conditional assignment.
>>>
>>> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
>>
>> This looks sane to me.
>>
>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>
> Before I commit I'll just change the commit title to:
>
> ath9k_htc: Replace a variable initialisation by an assignment in ath9k_htc_set_channel()

Sounds good to me.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/

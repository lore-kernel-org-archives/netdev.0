From: "Justin Mattock" <justinmattock@gmail.com>
Subject: Re: NETDEV WATCHDOG: wifi0: transmit timed out
Date: Wed, 30 Jul 2008 07:55:45 -0700
Message-ID: <dd18b0c30807300755y5dace2f0ma5f2c287f33f14d7@mail.gmail.com>
References: <20080729065859.2bcc65ed@infradead.org>
	 <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
	 <20080729215315.5a505fe7.komurojun-mbn@nifty.com>
	 <16453842.205951217418535898.komurojun-mbn@nifty.com>
	 <20080730062220.08b2779a@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Komuro <komurojun-mbn@nifty.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Arjan van de Ven" <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762569AbYG3O4H@vger.kernel.org>
In-Reply-To: <20080730062220.08b2779a@infradead.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2008 at 6:22 AM, Arjan van de Ven <arjan@infradead.org> wrote:
> On Wed, 30 Jul 2008 20:48:55 +0900 (JST)
> Komuro <komurojun-mbn@nifty.com> wrote:
>
>>
>> >
>> >"I have a hardware failure so I'll comment out the message that says
>> >so, and then I won't have a failure". Yeah that'll work well.
>>
>>
>> O.K. The madwifi should be fixed.
>> Thanks,
>
> madwifi has many bigger issues; it's been number 1 in the kerneloops
> top 10 for months and months now.
>
> Feel free to fix it.. I can't.. it's a proprietary/binary driver.
>
> --
> If you want to reach me at my work email, use arjan@linux.intel.com
> For development, discussion and tips for power savings,
> visit http://www.lesswatts.org
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

I should of written down the error that it was
giving(I can pull again to get the exact error)
from what I remember it was able to do the handshake
but wpa_supplicant would say CTRL-EVENT-CONNECTED then
CTRL-EVENT-DISCONNECTED
if its possible I would like to pull the wireless testing directory
and add that to 2.6.27-rc1. this way I can run ath9k, and the fresh
git "hot out of the oven",
I do have another computer now so reporting problems
makes it a whole lot easier than having one computer.

-- 
Justin P. Mattock

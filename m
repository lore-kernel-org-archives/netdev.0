From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: ti: wl18xx: add checks on wl18xx_top_reg_write() return value
Date: Wed, 28 Jun 2017 17:57:53 -0500
Message-ID: <20170628175753.Horde.jKsLaGOBj8-15rZyu1j0ooC@gator4166.hostgator.com>
References: <20170626230619.GA14831@embeddedgus>
 <20170628163844.56F26601EA@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170628163844.56F26601EA@smtp.codeaurora.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting Kalle Valo <kvalo@codeaurora.org>:

> "Gustavo A. R. Silva" <garsilva@embeddedor.com> wrote:
>
>> Check return value from call to wl18xx_top_reg_write(),
>> so in case of error jump to goto label out and return.
>>
>> Also, remove unnecessary value check before goto label out.
>>
>> Addresses-Coverity-ID: 1226938
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> The prefix should be "wl18xx:", I'll fix that.
>

Thanks, Kalle.
--
Gustavo A. R. Silva

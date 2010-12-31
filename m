From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: [PATCH 15/15]drivers:spi:dw_spi.c Typo change diable to disable.
Date: Thu, 30 Dec 2010 22:38:44 -0800
Message-ID: <4D1D7A74.3030803@gmail.com>
References: <1293750484-1161-6-git-send-email-justinmattock@gmail.com> <1293750484-1161-7-git-send-email-justinmattock@gmail.com> <1293750484-1161-8-git-send-email-justinmattock@gmail.com> <1293750484-1161-9-git-send-email-justinmattock@gmail.com> <1293750484-1161-10-git-send-email-justinmattock@gmail.com> <1293750484-1161-11-git-send-email-justinmattock@gmail.com> <1293750484-1161-12-git-send-email-justinmattock@gmail.com> <1293750484-1161-13-git-send-email-justinmattock@gmail.com> <1293750484-1161-14-git-send-email-justinmattock@gmail.com> <1293750484-1161-15-git-send-email-justinmattock@gmail.com> <20101231063433.GB1886@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <error27@gmail.com>, trivial@kernel.org,
	devel@driverdev.osuosl.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.k
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20101231063433.GB1886@bicker>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/30/2010 10:34 PM, Dan Carpenter wrote:
> On Thu, Dec 30, 2010 at 03:08:04PM -0800, Justin P. Mattock wrote:
>> The below patch fixes a typo "diable" to "disable". Please let me know if this
>> is correct or not.
>>
>> Signed-off-by: Justin P. Mattock<justinmattock@gmail.com>
>>
>> ---
>>   drivers/spi/dw_spi.c |    6 +++---
>
> You missed one from this file:
>
> /* Set the interrupt mask, for poll mode just diable all int */
>                                                ^^^^^^
> regards,
> dan carpenter
>
>

oh-man... my grepping wasn't so grepping after all.. thanks for that 
I'll resend this one

Justin P. Mattock

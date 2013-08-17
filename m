From: Haojian Zhuang <haojian.zhuang@gmail.com>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with regulator
 API
Date: Sat, 17 Aug 2013 10:03:31 +0800
Message-ID: <520ED9F3.1090906@gmail.com>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru> <52049C44.6030902@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Shiyan <shc_work@mail.ru>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	linux-arm-kernel@lists.infradead.org,
	Eric Miao <eric.y.miao@gmail.com>,
	Russell King <linux@arm.linux.org.uk>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52049C44.6030902@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2013 03:37 PM, Marc Kleine-Budde wrote:
> On 08/08/2013 02:00 PM, Alexander Shiyan wrote:
>> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
>> ---
>>   arch/arm/mach-pxa/icontrol.c         |  3 --
>>   arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------
>
> What's pxa's status of DT conversion? Do you (still) accept patches to
> board files?
>
> Marc
>

Since DT conversion isn't finished, I still accept the board files.
But this patch should be split into two parts. One is for pxa, and the
other one is for net.

Regards
Haojian

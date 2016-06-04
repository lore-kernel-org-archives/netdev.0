From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] b43: Remove unused phy_a code
Date: Fri, 3 Jun 2016 17:50:00 -0700
Message-ID: <575225B8.2040607@roeck-us.net>
References: <1464989566-1393-1-git-send-email-linux@roeck-us.net>
 <20160603233519.4606b1ef@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Michael_B=c3=bcsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160603233519.4606b1ef@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2016 02:35 PM, Michael B=FCsch wrote:
> On Fri,  3 Jun 2016 14:32:46 -0700
> Guenter Roeck <linux@roeck-us.net> wrote:
>
>> gcc-6 reports the following error with -Werror=3Dunused-const-variab=
le.
>>
>> drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
>> 	'b43_phyops_a' defined but not used
>>
>> Turns out a lot of code in this file is unused, so let's remove it.
>
>
> All a-phy code is usused.
> So you can basically remove the whole file and any other A-PHY code.

I love removing code. I'll resend with more code removed.

Guenter

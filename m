From: Ulf Hansson <ulf.hansson@linaro.org>
Subject: Re: [PATCH 4/4 v3] net/smsc911x: Provide common clock functionality
Date: Wed, 9 Jan 2013 17:32:20 +0100
Message-ID: <CAPDyKFqBVkJS=i_iULjj1e+LUgZQfVwH=sOHce7d7zbrHPFyqA@mail.gmail.com>
References: <1355937587-31730-4-git-send-email-lee.jones@linaro.org>
	<CACRpkda79O_b3Z8g7Sy7vMtW9neZU4x-Z=iEQgjqu4X5tFKyhw@mail.gmail.com>
	<20121220192441.GC14363@n2100.arm.linux.org.uk>
	<20121220203514.GN2691@gmail.com>
	<20121220205113.GD14363@n2100.arm.linux.org.uk>
	<20121221091306.GO2691@gmail.com>
	<20121221092421.GG14363@n2100.arm.linux.org.uk>
	<20121221114105.GP2691@gmail.com>
	<20130103111450.GC14714@gmail.com>
	<CACRpkda-4C+ezaZFSkxsNbmHnBN8RCoCeGePaOF-DzV0XnkzQw@mail.gmail.com>
	<20130109085555.GA31678@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert Marklund <robert.marklund@stericsson.com>,
	linus.walleij@stericsson.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130109085555.GA31678@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9 January 2013 09:55, Lee Jones <lee.jones@linaro.org> wrote:
> On Thu, 03 Jan 2013, Linus Walleij wrote:
>
>> On Thu, Jan 3, 2013 at 12:14 PM, Lee Jones <lee.jones@linaro.org> wr=
ote:
>>
>> > Some platforms provide clocks which require enabling before the
>> > SMSC911x chip will power on. This patch uses the new common clk
>> > framework to do just that. If no clock is provided, it will just
>> > be ignored and the driver will continue to assume that no clock
>> > is required for the chip to run successfully.
>> >
>> > Cc: Steve Glendinning <steve.glendinning@shawell.net>
>> > Cc: netdev@vger.kernel.org
>> > Signed-off-by: Lee Jones <lee.jones@linaro.org>
>>
>> Looks all right to me now:
>> Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
>
> I still need a maintiner Ack for this before I can push it.
>
> Anyone?
>
> --
> Lee Jones
> Linaro ST-Ericsson Landing Team Lead
> Linaro.org =E2=94=82 Open source software for ARM SoCs
> Follow Linaro: Facebook | Twitter | Blog
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Reviewed-by: Ulf Hansson <ulf.hansson@linaro.org>

From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: smsc: smc91x: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 4 Mar 2017 23:47:46 +0100
Message-ID: <CAC=8w91pQpSfb3_Ojng=t_HjMAZ7oAvLkGk6uit6PdWNFyzS0w@mail.gmail.com>
References: <1488622292-13200-1-git-send-email-tremyfr@gmail.com> <87k284wzw8.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nico@fluxnic.net, davem@davemloft.net, mugunthanvnm@ti.com,
        jarod@redhat.com, felipe.balbi@linux.intel.com,
        rmk+kernel@armlinux.org.uk, fw@strlen.de, jeremy.linton@arm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k284wzw8.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Robert,

On 3/4/17, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
> Philippe Reynes <tremyfr@gmail.com> writes:
>
>> The ethtool api {get|set}_settings is deprecated.
>> We move this driver to new api {get|set}_link_ksettings.
>>
>> As I don't have the hardware, I'd be very pleased if
>> someone may test this patch.
> I have the hardware.
>
> Do you want anything specific to be tested, like setting full/half duplex
> or
> autoneg through ethtool, or just a driver probe/usage ?

I would be very nice if you could test the setting of half/full
duplex, speed, ...


> Cheers.
>
> --
> Robert
>

Thanks a lot for this test,

Regards,
Philippe

From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH V4] r8152: add Linksys USB3GIGV1 id
Date: Mon, 2 Oct 2017 10:21:19 -0700
Message-ID: <CANEJEGtejLnPnPoaZWau=RgdKoRSLoMbo2GgjJJE-He-iPPgOg@mail.gmail.com>
References: <20170928183500.61199-1-grundler@chromium.org> <20171001.223954.160035131695050852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Grant Grundler <grundler@chromium.org>,
        Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001.223954.160035131695050852.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 1, 2017 at 10:39 PM, David Miller <davem@davemloft.net> wrote:
> From: Grant Grundler <grundler@chromium.org>
> Date: Thu, 28 Sep 2017 11:35:00 -0700
>
>> This linksys dongle by default comes up in cdc_ether mode.
>> This patch allows r8152 to claim the device:
>>    Bus 002 Device 002: ID 13b1:0041 Linksys
>>
>> Signed-off-by: Grant Grundler <grundler@chromium.org>
>
> Applied, thanks.

thanks David, Doug, Oliver! :)

cheers,
grant

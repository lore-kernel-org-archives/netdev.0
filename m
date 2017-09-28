From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH V3] r8152: add Linksys USB3GIGV1 id
Date: Thu, 28 Sep 2017 08:11:07 -0700
Message-ID: <CAD=FV=Wmmw9gsqRXe5Mt4LfNzXWW4=AXpDsBJH7jROLOkmKpLw@mail.gmail.com>
References: <20170927172802.80654-1-grundler@chromium.org> <CAD=FV=U-zMEQ8=_96SMENmcBywG0hSrDvebXUxGGbAur_2T-4g@mail.gmail.com>
 <CANEJEGvK94v_SV9xWmDaiA4CZOiroKZVhfCH4vydF6_Su2_PyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>,
        linux-usb <linux-usb@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGvK94v_SV9xWmDaiA4CZOiroKZVhfCH4vydF6_Su2_PyA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Sep 27, 2017 at 5:07 PM, Grant Grundler <grundler@chromium.org> wrote:
>>>  #define DELL_VENDOR_ID         0x413C
>>>  #define REALTEK_VENDOR_ID      0x0bda
>>>  #define SAMSUNG_VENDOR_ID      0x04e8
>>> +#define LINKSYS_VENDOR_ID      0x13b1
>>>  #define LENOVO_VENDOR_ID       0x17ef
>>
>> Slight nit that "LI" sorts after "LE".  You got it right in the other case...
>
> The list isn't sorted by any rational thing I can see.  I managed to
> check my OCD reaction to sort the list numerically. :)

Whoops, you're right.  It seems to be in a random order.  I just saw
LE, LI, and N sorted properly and jumped to a conclusion.  In any
case, if it's all the same to you it'd be nice if you were consistent
between LENOVO/LINKSYS in the two files.  :-P

-Doug

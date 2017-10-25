From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] wimax/i2400m: Remove VLAIS
Date: Wed, 25 Oct 2017 23:01:40 +0200
Message-ID: <CAK8P3a3ytCHcgSARDXNMPNbKdEMf6_C-DrR64Ai0G23Krmj=BQ@mail.gmail.com>
References: <20171009194153.30467-1-mka@chromium.org> <20171024194659.GC96615@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
        linux-wimax@intel.com, Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Behan Webster <behanw@converseincode.com>,
        Mark Charlebois <charlebm@gmail.com>,
        Guenter Roeck <groeck@chromium.org>
To: Matthias Kaehlcke <mka@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024194659.GC96615@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 9:46 PM, Matthias Kaehlcke <mka@chromium.org> wrote:
> El Mon, Oct 09, 2017 at 12:41:53PM -0700 Matthias Kaehlcke ha dit:

>> +             u8 cmd_payload[];
>>       } __packed *buf;
>>       struct i2400m_bootrom_header ack;
>
> ping
>
> any comments on this?

What for? The patch is clearly correct and Davem already merged it in
4.14, right?

       Arnd

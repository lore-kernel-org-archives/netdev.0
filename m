From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH, RESEND] ssb: mark ssb_bus_register as __maybe_unused
Date: Sat, 16 Jan 2016 15:44:23 +0100
Message-ID: <CACna6ryvDFHqwJ3ExURcyFT2ZaT9fS9v36wCnJfze5BLnE88og@mail.gmail.com>
References: <8128014.DbbgBtKY3z@wuerfel>
        <8760ywd5fe.fsf@kamboji.qca.qualcomm.com>
        <4037550.DMaVTE01Aq@wuerfel>
        <87bn8l7miw.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        Hauke Mehrtens <hauke@hauke-m.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Michael Buesch <m@bues.ch>,
        Network Development <netdev@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <87bn8l7miw.fsf@kamboji.qca.qualcomm.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 16 January 2016 at 13:10, Kalle Valo <kvalo@codeaurora.org> wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
>
>> On Thursday 14 January 2016 08:46:29 Kalle Valo wrote:
>>> I can take it. For historical reasons ssb patches go through my
>>> wireless-drivers trees.
>>
>> I found this in my backlog, and I believe it still applies. Can you =
take
>> that one too?
>
> I'm not sure what you mean here, I can take any ssb patch if it's ok =
for
> Michael or Rafal :)
>
> Just please submit the patch properly (with S-o-B line) and CC
> linux-wireless so that it goes to patchwork.

It was already sent once and Acked by Michael:
https://patchwork.kernel.org/patch/7543191/

The problem was not cc-ing linux-wireless so it wasn't picked by the
linux-wireless patchwork.

--=20
Rafa=C5=82

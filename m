From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 05/18] net: use ARRAY_SIZE
Date: Tue, 3 Oct 2017 11:09:50 +0300
Message-ID: <CAHp75Vfz=77TB3Mt_=CZUBzndwRE_XhrOFgdJ-HLUwrfg8a=kA@mail.gmail.com>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
 <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr> <CAHp75VfC2e+h8GCiB-1Rbe=_z3siBBo0WfqEf3qz8yWh8Cm3RQ@mail.gmail.com>
 <20171002212214.30d7013a@blatinox-laptop.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <
To: =?UTF-8?B?SsOpcsOpbXkgTGVmYXVyZQ==?= <jeremy.lefaure@lse.epita.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002212214.30d7013a@blatinox-laptop.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 3, 2017 at 4:22 AM, J=C3=A9r=C3=A9my Lefaure
<jeremy.lefaure@lse.epita.fr> wrote:
> On Mon, 2 Oct 2017 16:07:36 +0300
> Andy Shevchenko <andy.shevchenko@gmail.com> wrote:
>
>> > +       {&gainctrl_lut_core0_rev0, ARRAY_SIZE(gainctrl_lut_core0_rev0)=
, 26, 192,
>> > +        32},
>>
>> For all such cases I would rather put on one line disregard checkpatch
>> warning for better readability.
> I agree that it would be better. I didn't know that it was possible to
> not follow this rule for anything else than a string.

IMO, it increases readability quite enough to overrule checkpatch recomenda=
tion.

--=20
With Best Regards,
Andy Shevchenko

From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 5/5] net-next:asix: update VERSION and white space changes
Date: Tue, 15 Nov 2011 07:58:11 -0800
Message-ID: <CANEJEGtj4ZMd2ewrMjYLjor2216UGWBhfywDEtAP0Z_+cMGqmQ@mail.gmail.com>
References: <CANEJEGuzdxDuVysuAJPcdC7-mywa8B8JggVHe_VMTK_1j4QguQ@mail.gmail.com>
	<20111114.213255.2061756136146824209.davem@davemloft.net>
	<20111114.214151.1988775203701808195.davem@davemloft.net>
	<20111114.214542.1423779515286773837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw, kernel@teksavvy.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111114.214542.1423779515286773837.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2011 at 6:45 PM, David Miller <davem@davemloft.net> wro=
te:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 14 Nov 2011 21:41:51 -0500 (EST)
>
>> Come on man... are you kidding me?

Dave,
my apologies. That's obviously my fail.

The problem is I can't test your git tree on my systems...but I should
have at least compile tested it. Or just submitted the changes
straight from chromium.org tree. *sigh*

> Want to know what really pisses me off about this?
>
> All of Mark Lord's hard work to bring the entire vendor driver over
> was thrown out.

Not entirely correct as Mark pointed out. I was able to convince ASIX
they should be working with Mark and they committed to doing so.

> And it was thrown out in favor of this! =C2=A0Code that doesn't even
> compile.

*sigh* sorry...I'll resubmit the entire mess and compile test first. /o=
\

thanks for your patience,
grant

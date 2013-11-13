From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Wed, 13 Nov 2013 09:54:18 +0100
Message-ID: <CAMuHMdXyqOATvE8e=3Ed17bwiDRE8w=B=xKuYwd5qorxqA0BJg@mail.gmail.com>
References: <20131112.161253.601617211955537751.davem@davemloft.net>
	<5282BC76.5050701@cogentembedded.com>
	<CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
	<20131112.181629.742226266240112179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Linux/m68k" <linux-m68k@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20131112.181629.742226266240112179.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2013 at 12:16 AM, David Miller <davem@davemloft.net> wrote:
>>> And remember about checkpatch.pl which was hardly content with the patch.
>>
>> Only because checkpatch looks at the _new_ lines, and doesn't compare the
>> styles of the old and new lines.
>
> You really should fix the line you are changing to use tabs, please respin
> with this in mind, thanks.

As that would add more to the TAB/space mess^H^H^Hix, I prepended a
patch to fix all whitespace errors.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

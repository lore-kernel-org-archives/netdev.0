From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Thu, 14 Nov 2013 09:37:32 +0100
Message-ID: <CAMuHMdWN5KGYYZuMYF+cH8dtT9cuaWQNJaaE4wC0LXRVBBrmyw@mail.gmail.com>
References: <CAMuHMdVn6MFbXgdE_teYW10OfYBjyZsN7v2yTTAsKj0kXao7Hw@mail.gmail.com>
	<20131112.181629.742226266240112179.davem@davemloft.net>
	<CAMuHMdXyqOATvE8e=3Ed17bwiDRE8w=B=xKuYwd5qorxqA0BJg@mail.gmail.com>
	<20131113.151301.100218641838867631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Linux/m68k" <linux-m68k@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20131113.151301.100218641838867631.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, Nov 13, 2013 at 9:13 PM, David Miller <davem@davemloft.net> wrote:
>> On Wed, Nov 13, 2013 at 12:16 AM, David Miller <davem@davemloft.net> wrote:
>>>>> And remember about checkpatch.pl which was hardly content with the patch.
>>>>
>>>> Only because checkpatch looks at the _new_ lines, and doesn't compare the
>>>> styles of the old and new lines.
>>>
>>> You really should fix the line you are changing to use tabs, please respin
>>> with this in mind, thanks.
>>
>> As that would add more to the TAB/space mess^H^H^Hix, I prepended a
>> patch to fix all whitespace errors.
>
> I implicitly asked you not to do this, now things are more difficult
> and your original change will take longer to integrate.

Sorry, I didn't get that message. I was puzzled by your request to correct
the whitespace of the lines I touched only, which causes them to stand out
in a block of old non-compliant whitespace.

> Becuase now it isn't a patch set I can easily just apply quickly in
> the current merge window, and it's therefore a series you'll have to
> resubmit later when the merge window closes and the net-next tree
> opens up again.

Nevermind, it's not urgent nor critical. I will resubmit for the next merge
window.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

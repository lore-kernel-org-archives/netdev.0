From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Mon, 22 Nov 2004 22:07:27 +0000
Message-ID: <41A2631F.5020804@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041122213008.GA9618@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>I didn't see any crashes or hangs with use_dac enabled (or rather, not 
>>disabled).
> 
> 
> It defaults to 0. Set it to 1 if you dare (once the current issues are
> fixed, ok ? :o) ).

Yeah. ;)

[snip]
 > I'll check if there is something relevant for ethtool on RH bugzilla.
 > It should not segfault.

OK. I will try debugging it using gdb later (probably not today), to see 
where it segfaults.

[snip]
>>Sadly my box won't boot, if I disable ACPI.
> 
> 
> Can you give a look at:
> http://forums.gentoo.org/viewtopic.php?t=122145%22%22
> 
> Ac*r, laptop, acpi and x64 are making me paranoid.

Sure. It will take me a while to digest all that stuff! I probably won't 
be able to do that for a couple of days. There is a fixed-up ACPI file 
for the Acer Aspire 1523LMi. I probably need to do some work. Earlier 
versions of the 1520 series came with Broadcom GigE.

[snip]
>>From your ethtool patch, it looks like I have a 8110. I did search 
>>their specs for version registers, etc., but I could not see them. Where 
>>did you get your datasheet from for the 8110?
> 
> 
> I got my rtl8169spec-121.pdf from Realtek's website when their search
> engine was still working. Now you'd better use Google.
[snip]

Thanks, I've got a copy now. Googling for that exact filename gives a 
site containing specifications for various network chips.

Thanks for your help!

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek

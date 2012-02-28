From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH 1/2] iptables: Merge libip6t_LOG and libipt_LOG into libxt_LOG
Date: Tue, 28 Feb 2012 17:15:59 +0100
Message-ID: <CAA93jw5AfWbU8Gsx1WtJSkTox7bMAjkeuojaMXgwWgdAyROMGw@mail.gmail.com>
References: <1328911856-19260-1-git-send-email-richard@nod.at>
	<1328911856-19260-2-git-send-email-richard@nod.at>
	<20120225133816.GA15864@1984>
	<4F4CFB6D.4000403@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org, basti@b-bl.de
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F4CFB6D.4000403@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 5:06 PM, Richard Weinberger <richard@nod.at> wr=
ote:
> Am 25.02.2012 14:38, schrieb Pablo Neira Ayuso:
>> On Fri, Feb 10, 2012 at 11:10:51PM +0100, Richard Weinberger wrote:
>>> libip6t_LOG and libipt_LOG share a lot of common code, merge them
>>> to recude duplicate code.
>>
>> I have applied this to the net-next branch of iptables.
>>
>> See git.netfilter.org
>>
>> I'll merge it to master once linux kernel 3.3 is released.
>
> Okay. What about the ring buffer feature?
> Is there anything missing?

I'm under the impression that the ecn related changes didn't make it
as yet. I'm in a position to test that stuff this month, if it needs
further testing and hasn't actually made it in.

> Thanks,
> //richard
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

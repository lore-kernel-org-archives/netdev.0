From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Backporting the Linux kernel, for good - was: Re: semantic patch inference
Date: Fri, 9 Sep 2011 15:28:47 -0700
Message-ID: <CAB=NE6UAxOObHye4Tg7whY3mOSYm7mR9W3+kG+3GHjjqFip2rg@mail.gmail.com>
References: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw@mail.gmail.com>
 <Pine.LNX.4.64.1109092245170.9242@ask.diku.dk> <CAB=NE6VVaAgyaEX0iTuuj=r1-Vsi5TgAyCj4+3J=QerrJTWs_Q@mail.gmail.com>
 <Pine.LNX.4.64.1109092352230.13368@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Andersen <jespera@diku.dk>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f42.google.com ([209.85.216.42]:39459 "EHLO
	mail-qw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759096Ab1IIW3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 18:29:08 -0400
In-Reply-To: <Pine.LNX.4.64.1109092352230.13368@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2011 at 2:53 PM, Julia Lawall <julia@diku.dk> wrote:
> On Fri, 9 Sep 2011, Luis R. Rodriguez wrote:
>> On Fri, Sep 9, 2011 at 1:48 PM, Julia Lawall <julia@diku.dk> wrote:
>> > I guess that the patch that spdiff will receive will already conta=
in the
>> > appropriate #ifs, so we don't have to be concerned about them.
>>
>> That is correct.
>>
>> >=C2=A0We just add them in as is.
>>
>> I do not follow, add what?
>
> Sorry. =C2=A0The + code. The #ifdefs ad the compatibility code. =C2=A0=
We don't have
> to interpret it, so we don't care whether it is only related to kerne=
l
> version numbers or something more complex.

Ah yes, indeed!

  Luis

From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 18:14:53 -0700
Message-ID: <CA+55aFyENEpGJmTq55=n0_gDiF6RQmdKw-ts4AdQAFQJ1TkF-Q@mail.gmail.com>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
 <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
 <4E76864D.4080907@ll.mit.edu> <20110918.210344.570661374586887894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: david.ward@ll.mit.edu, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeremy Kerr <jk@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48626 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab1ISBPR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 21:15:17 -0400
In-Reply-To: <20110918.210344.570661374586887894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm. I *think* the right person for patchwork issues is Jeremy Kerr,
but I migth be wrong..

Jeremy, the fact that apparently patchworks loses proper names is a
killer feature - but very much in the wrong meaning of "killer". Any
way to make sure that doesn't happen?

                    Linus

On Sun, Sep 18, 2011 at 6:03 PM, David Miller <davem@davemloft.net> wro=
te:
> From: David Ward <david.ward@ll.mit.edu>
> Date: Sun, 18 Sep 2011 20:01:17 -0400
>
>> On 09/18/2011 02:06 PM, Linus Torvalds wrote:
>>> 2011/9/17 David Miller<davem@davemloft.net>:
>>>> dpward (2):
>>>> =A0 =A0 =A0 net: Make flow cache namespace-aware
>>>> =A0 =A0 =A0 net: Handle different key sizes between address famili=
es in flow cache
>>>>
>>>> nhorman (1):
>>>> =A0 =A0 =A0 net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
>>>>
>>>> rajan.aggarwal85@gmail.com (1):
>>>> =A0 =A0 =A0 net/can/af_can.c: Change del_timer to del_timer_sync
>>> Guys, if somebody has such a broken email setup that they don't eve=
n
>>> show their own name, don't take patches from them.
>>
>> At least in my case, that is Patchwork's fault. =A0My name only star=
ted
>> showing up like that in commits after I registered for an account
>> (http://patchwork.ozlabs.org/register/), and I don't see any way to
>> change the way my name appears in the Patchwork profile options.
>>
>> The emails I sent to the netdev list showed my full name; see:
>> http://marc.info/?l=3Dlinux-netdev&m=3D131527867326729&w=3D2
>> http://marc.info/?l=3Dlinux-netdev&m=3D131527879226819&w=3D2
>
> I hope some mechanism can be created to undo this behavior.
>

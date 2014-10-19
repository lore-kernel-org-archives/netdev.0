From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: s6gmac: remove driver
Date: Sun, 19 Oct 2014 13:28:01 -0400 (EDT)
Message-ID: <20141019.132801.424495087167944921.davem@davemloft.net>
References: <1413672545-8535-1-git-send-email-dg@emlix.com>
	<20141019.124542.141206969262552652.davem@davemloft.net>
	<CAMo8BfJ-wvDoDmm+HLHvC3VRUshdqU4eJchOGYt_YJsUktap8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dg@emlix.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jcmvbkbc@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMo8BfJ-wvDoDmm+HLHvC3VRUshdqU4eJchOGYt_YJsUktap8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Max Filippov <jcmvbkbc@gmail.com>
Date: Sun, 19 Oct 2014 21:26:05 +0400

> On Sun, Oct 19, 2014 at 8:45 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Daniel Gl=F6ckner <dg@emlix.com>
>> Date: Sun, 19 Oct 2014 00:49:05 +0200
>>
>>> The s6000 Xtensa support is removed from the kernel. There are no
>>> other chips using this driver.
>>
>> That's not what I see in Linus's current tree:
>=20
> David, s6000 removal is queued for 3.18.

Then there is zero reason for me to apply this to my networking
tree.

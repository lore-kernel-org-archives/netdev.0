From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH 00/15] change default_llseek action
Date: Wed, 15 Sep 2010 09:06:25 -0700
Message-ID: <AANLkTimCsuTXM3e0D8zPEsugd2W9c7ziTK+Xx2wmkJb0@mail.gmail.com>
References: <1284495763-7506-1-git-send-email-arnd@arndb.de> <20100915193926.ae2fe838.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org, Jeremy Kerr <jk@ozlabs.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Julia Lawall <julia@diku.dk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	Tony Lindgren <tony@atomide.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100915193926.ae2fe838.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2010 at 2:39 AM, Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
> Hi Arnd,
>
> On Tue, 14 Sep 2010 22:22:28 +0200 Arnd Bergmann <arnd@arndb.de> wrot=
e:
>>
>> Stephen, please add
>> git+ssh://master.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git ll=
seek
>
> Added from today.
>
> Thanks for adding your subsystem tree as a participant of linux-next.=
 =C2=A0As
> you may know, this is not a judgment of your code. =C2=A0The purpose =
of
> linux-next is for integration testing and to lower the impact of
> conflicts between subsystems in the next merge window.
>
> You will need to ensure that the patches/commits in your tree/series =
have
> been:
> =C2=A0 =C2=A0 * submitted under GPL v2 (or later) and include the Con=
tributor's
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Signed-off-by,

I should note this should say the code should be GPL-compatible, it
doesn't need to be GPLv2 (or later). Furthermore the contributors of
the subsystem respect the individual licenses of the files through the
Developers Certificate of Origin, which tells the developers what the
meaning of Signed-off-by means.

  Luis

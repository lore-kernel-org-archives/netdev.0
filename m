From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 7 Aug 2013 10:29:18 +0200
Message-ID: <CA+icZUW+uxCsvPYcY2RRvMxRVzaBLuH9u8M4ziQNWXv=nk4b2w@mail.gmail.com>
References: <20130807155443.a0355d0429f3e0b4ccbed261@canb.auug.org.au>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Phil Sutter <phil@nwl.cc>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	wireless <linux-wireless@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130807155443.a0355d0429f3e0b4ccbed261@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 7, 2013 at 7:54 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Changes since 20130806:
>
> The ext4 tree lost its build failure.
>
> The mvebu tree gained a build failure so I used the version from
> next-20130806.
>
> The akpm tree gained conflicts against the ext4 tree.
>
> ----------------------------------------------------------------------------
>

[ CC some netdev and wireless folks ]

Yesterday, I discovered an issue with net-next.
The patch in [1] fixed the problems in my network/wifi environment.
Hannes confirmed that virtio_net are solved, too.
Today's next-20130807 still needs it for affected people.

- Sedat -

[1] http://marc.info/?l=linux-netdev&m=137582524017840&w=2
[2] http://marc.info/?l=linux-netdev&m=137583048219416&w=2
[3] http://marc.info/?t=137579712800008&r=1&w=2

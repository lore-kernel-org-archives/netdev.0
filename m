From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v6 7/9] forcedeth: implement ndo_get_stats64() API
Date: Thu, 17 Nov 2011 09:39:21 -0800
Message-ID: <CAG88wWbiwVKUVtQxV=FzBTfaCngeGYXL9M_00NQKCgbEqic4-w@mail.gmail.com>
References: <cover.1321481064.git.david.decotigny@google.com>
 <185a0f33c69ff07e8fe3482828b368371420bf47.1321481064.git.david.decotigny@google.com>
 <1321511678.3274.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321511678.3274.30.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2011 at 10:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> You should use the _bh variants.

Oooops. It's unforgivable: the sky2 implementation you mentioned in a
previous message was the simple and right model to follow. Grrrrrr.
Sending a fix shortly.

Thanks!

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v6 3/9] kbuild: document RPS/XPS network
 Kconfig options
Date: Thu, 17 Nov 2011 02:54:03 +0000
Message-ID: <1321498443.2885.80.camel@deadeye>
References: <cover.1321481064.git.david.decotigny@google.com>
	 <c7e7b57596f9a06b1c40c8b6e671cc6ac69dd304.1321481064.git.david.decotigny@google.com>
	 <1321485122.2709.55.camel@bwh-desktop>
	 <CAG88wWZ853cHkykNbQ+Lqrk_D1p-SCmB0Y29YE6GpSSUORwCxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	Tom Herbert <therbert@google.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG88wWZ853cHkykNbQ+Lqrk_D1p-SCmB0Y29YE6GpSSUORwCxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-16 at 17:54 -0800, David Decotigny wrote:
> On Wed, Nov 16, 2011 at 3:12 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Wed, 2011-11-16 at 14:15 -0800, David Decotigny wrote:
> >> This adds a description of RPS/XPS options and allow them to be
> >> changed at make menuconfig time.
> >
> > I'm not sure why you think this is necessary.
> 
> On my copy, make menuconfig doesn't let me change these CONFIG_ items,
> unless I add the string after "boolean", which this patch does. I
> agree, the help I added after is pure cosmetic.
[...]

I know, but I'm asking why you think it's necessary to make them
optional.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

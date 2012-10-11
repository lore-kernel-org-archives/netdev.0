From: David Howells <dhowells@redhat.com>
Subject: [GIT PULL] Disintegrate UAPI for wimax
Date: Thu, 11 Oct 2012 09:07:52 +0100
Message-ID: <11849.1349942872@warthog.procyon.org.uk>
References: <3A78FAA0EC814D4B8ECC99B3AB32B33208612DA4@fmsmsx110.amr.corp.intel.com> <30770.1349789450@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, linux-wimax <linux-wimax@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3A78FAA0EC814D4B8ECC99B3AB32B33208612DA4@fmsmsx110.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

Can you pull wimax as well?

Sorry about this, but it seems like the majority of the non-arch trees need to
go through the networking tree.

Perez-Gonzalez, Inaky <inaky.perez-gonzalez@intel.com> wrote:

> > From: David Howells [mailto:dhowells@redhat.com]
> > 
> > Can you merge the following branch into the wimax tree please.
> > ...
> 
> This can be submitted straight to Dave Miller, as there is no separate wimax
> tree anymore, it is in pure maintenance mode.
> 
> BTW: thanks for tackling the UAPI issue
> 
> Acked-by: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

Thanks,
David
---
The following changes since commit 9e2d8656f5e8aa214e66b462680cf86b210b74a8:

  Merge branch 'akpm' (Andrew's patch-bomb) (2012-10-09 16:23:15 +0900)

are available in the git repository at:


  git://git.infradead.org/users/dhowells/linux-headers.git tags/disintegrate-wimax-20121009

for you to fetch changes up to 1e256b340d9574fd1bf31b73f16c4c474502692c:

  UAPI: (Scripted) Disintegrate include/linux/wimax (2012-10-09 09:49:08 +0100)

----------------------------------------------------------------
UAPI Disintegration 2012-10-09

----------------------------------------------------------------
David Howells (1):
      UAPI: (Scripted) Disintegrate include/linux/wimax

 include/linux/wimax/Kbuild              | 1 -
 include/uapi/linux/wimax/Kbuild         | 1 +
 include/{ => uapi}/linux/wimax/i2400m.h | 0
 3 files changed, 1 insertion(+), 1 deletion(-)
 rename include/{ => uapi}/linux/wimax/i2400m.h (100%)
.

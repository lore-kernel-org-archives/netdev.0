From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH v2] uapi glibc compat: fix compile errors when glibc
 net/if.h included before linux/if.h
Date: Tue, 10 May 2016 01:15:13 +0300
Message-ID: <20160509221513.GF5160@lakka.kapsi.fi>
References: <1461512707-23058-1-git-send-email-mikko.rapeli@iki.fi>
 <CA+5PVA7eQLc1UGbaJg9B2BY-6L35Vx3Enpc6Ez9ySucGsY+o6A@mail.gmail.com>
 <20160509213535.GA23623@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"David S. Miller" <davem@davemloft.net>,
	Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Jan Engelhardt <jengelh@inai.de>,
	Waldemar Brodkorb <mail@waldemar-brodkorb.de>,
	Gabriel Laskar <gabriel@lse.epita.fr>,
	netfilter-devel@vger.kernel.org,
	libc-alpha <libc-alpha@sourceware.org>, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160509213535.GA23623@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 09, 2016 at 11:35:35PM +0200, Pablo Neira Ayuso wrote:
> It seems linux-netdev was not Cc'ed. I cannot find this in David's
> patchwork [1].
> 
> @Mikko: Could you resubmit including netdev@vger.kernel.org? Thanks.

Done: http://patchwork.ozlabs.org/patch/620262/

-Mikko

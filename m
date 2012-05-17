From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH net-next] hp100: delete VG/AnyLAN hp100
Date: Fri, 18 May 2012 00:28:43 +0200
Message-ID: <20120517222843.GA30680@electric-eye.fr.zoreil.com>
References: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com> <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com> <4FB52C99.6010303@windriver.com> <20120517212039.GC27789@windriver.com> <1337292547.8872.20.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-kernel@vger.kernel.org, JBottomley@parallels.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joel Soete <soete.joel@scarlet.be>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337292547.8872.20.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> :
> On Thu, 2012-05-17 at 17:20 -0400, Paul Gortmaker wrote:
> > [Re: [PATCH 2/5] drivers/net: delete all code/drivers depending on CONFIG_MCA
> 
> If we're removing really old and unused stuff,
> how about the VG/AnyLAN driver too?

Joel Soete appeared to actively use a PCI one with recent kernels back
in 2007.

-- 
Ueimor

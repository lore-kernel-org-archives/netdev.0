From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH net-next] hp100: delete VG/AnyLAN hp100
Date: Fri, 18 May 2012 21:28:08 +0200
Message-ID: <20120518192808.GA19446@electric-eye.fr.zoreil.com>
References: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com> <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com> <4FB52C99.6010303@windriver.com> <20120517212039.GC27789@windriver.com> <1337292547.8872.20.camel@joe2Laptop> <20120517222843.GA30680@electric-eye.fr.zoreil.com> <1337295024.8872.33.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Soete <soete.joel@scarlet.be>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-kernel@vger.kernel.org, JBottomley@parallels.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337295024.8872.33.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> :
[...]
> I saw people using TR adapters with Linux as of 2008/9.
> 
> That doesn't mean it's common or make it desirable to
> keep TR in the current kernel tree though.

I'll leave token ring PCI drivers where they are for now.

> Is VG/AnyLAN different?

Your own word: "unused". I see nothing wrong asking users if they
still care. If no one cares about the hp100, fine.

-- 
Ueimor

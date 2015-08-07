From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: thunderx: remove effective "default y" from
 Kconfig if ARCH_THUNDER=y
Date: Thu, 06 Aug 2015 23:58:49 -0700 (PDT)
Message-ID: <20150806.235849.1866973399577659068.davem@davemloft.net>
References: <1438716355-11515-1-git-send-email-ijc@hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: ijc@hellion.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438716355-11515-1-git-send-email-ijc@hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ijc@hellion.org.uk>
Date: Tue,  4 Aug 2015 20:25:55 +0100

> As well as for kernels built only for ThunderX ARCH_THUNDERX is also enabled
> for kernels which support multiple platforms (such as distro kernels). Thus
> "default ARCH_THUNDER" is inappropriate.
> 
> I believe default m is equally frowned upon, so remove the line completely
> rather than "default m if ARCH_THUNDER".
> 
> Signed-off-by: Ian Campbell <ijc@hellion.org.uk>

Applied.

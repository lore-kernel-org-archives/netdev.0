From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 08:59:40 -0800
Message-ID: <1449075580.6379.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
	 <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
	 <20151201.143047.82022857078130793.davem@davemloft.net>
	 <CA+sq2CduMnsh_R9zTRMjWT=F5=9U3si-5nO6-gFvGCO9czkDdA@mail.gmail.com>
	 <1449062733.32764.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+sq2CfWC0kcxKj1kqMEU3+y9aovqDdpn2G72n5ON9T3Hzew_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Pavel Fedin <p.fedin@samsung.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+sq2CfWC0kcxKj1kqMEU3+y9aovqDdpn2G72n5ON9T3Hzew_w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-02 at 22:20 +0530, Sunil Kovvuri wrote:
> >
> > If the performance increase is 4 %, then surely using twice more memory
> > is not worth it.
> I haven't mentioned anywhere that i am seeing 4% increase in performance.

Yes, this is the complain I made :

No numbers, just a patch increasing ring size by a 100% factor !

I really hope you'll have very convincing numbers, especially if your
driver does not implement BQL.

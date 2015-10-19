From: Akemi Yagi <amyagi@gmail.com>
Subject: Re: [PATCH v2 net-next] netfilter: ipset: Fixing unnamed union initg
Date: Mon, 19 Oct 2015 13:51:19 -0700
Message-ID: <CABA31DrViktaYpz3nO1G4TPGpovhZ+O1YfwhfQNm7d7XPsAcAA@mail.gmail.com>
References: <1440222251-21132-1-git-send-email-eladr@mellanox.com>
 <alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu> <20150822184448.GA3610@salvia>
 <20150828225943.GA22393@salvia> <CABA31DoF20veE1c_TxY_xZ=Zk0ThmwGCAthbLb8SJLu608rxHg@mail.gmail.com>
 <CAHTgTXU+A6Rg8oT0iUDCyTCRtTbBWEe9oDxCY6fEFNj-1v1-xA@mail.gmail.com>
 <CABA31DqmtsrK-O7j=X4mJYSBz2rMV28u0mZ=z2RWEJ4w8pTGBQ@mail.gmail.com> <20150913115201.GE3691@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Elad Raz <eladr@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netfilter-devel@vger.kernel.org,
	Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Jiri Pirko <jiri@resnulli.us>,
	Patrick McHardy <kaber@trash.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Anton Danilov <littlesmilingcloud@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Cong Wang <cwang@twopensource.com>,
	Alan Bartlett <ajb@elrepo.org>,
	Vinson Lee <vlee@twopensource.com>, stable@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150913115201.GE3691@salvia>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 13, 2015 at 4:52 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Sat, Sep 12, 2015 at 06:01:27PM -0700, Akemi Yagi wrote:
>> Thanks to all for this effort. The patch is finally in the mainline
>> kernel 4.3-rc1 released today. Now I wish backporting to the 4.2
>> branch goes smoothly.
>
> It's on its path to 4.2:
>
> http://patchwork.ozlabs.org/patch/516795/
>
> so I think this will hit 4.2 soon. Thanks!

Yes, I finally see it in 4.2.4 to be released in the next few days.

Thank you,

Akemi

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 net-next] netfilter: ipset: Fixing unnamed union initg
Date: Sun, 13 Sep 2015 13:52:01 +0200
Message-ID: <20150913115201.GE3691@salvia>
References: <1440222251-21132-1-git-send-email-eladr@mellanox.com>
 <alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu>
 <20150822184448.GA3610@salvia>
 <20150828225943.GA22393@salvia>
 <CABA31DoF20veE1c_TxY_xZ=Zk0ThmwGCAthbLb8SJLu608rxHg@mail.gmail.com>
 <CAHTgTXU+A6Rg8oT0iUDCyTCRtTbBWEe9oDxCY6fEFNj-1v1-xA@mail.gmail.com>
 <CABA31DqmtsrK-O7j=X4mJYSBz2rMV28u0mZ=z2RWEJ4w8pTGBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Akemi Yagi <amyagi@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABA31DqmtsrK-O7j=X4mJYSBz2rMV28u0mZ=z2RWEJ4w8pTGBQ@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 12, 2015 at 06:01:27PM -0700, Akemi Yagi wrote:
> Thanks to all for this effort. The patch is finally in the mainline
> kernel 4.3-rc1 released today. Now I wish backporting to the 4.2
> branch goes smoothly.

It's on its path to 4.2:

http://patchwork.ozlabs.org/patch/516795/

so I think this will hit 4.2 soon. Thanks!

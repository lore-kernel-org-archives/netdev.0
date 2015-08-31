From: Vinson Lee <vlee@twopensource.com>
Subject: Re: [PATCH v2 net-next] netfilter: ipset: Fixing unnamed union initg
Date: Mon, 31 Aug 2015 00:16:18 -0700
Message-ID: <CAHTgTXU+A6Rg8oT0iUDCyTCRtTbBWEe9oDxCY6fEFNj-1v1-xA@mail.gmail.com>
References: <1440222251-21132-1-git-send-email-eladr@mellanox.com>
	<alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu>
	<20150822184448.GA3610@salvia>
	<20150828225943.GA22393@salvia>
	<CABA31DoF20veE1c_TxY_xZ=Zk0ThmwGCAthbLb8SJLu608rxHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Akemi Yagi <amyagi@gmail.com>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Elad Raz <eladr@mellanox.com>, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netfilter-devel@vger.kernel.org,
	Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Jiri Pirko <jiri@resnulli.us>,
	Patrick McHardy <kaber@trash.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Anton Danilov <littlesmilingcloud@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Cong Wang <cwang@twopensource.com>,
	Alan Bartlett <ajb@elrepo.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CABA31DoF20veE1c_TxY_xZ=Zk0ThmwGCAthbLb8SJLu608rxHg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 28, 2015 at 4:21 PM, Akemi Yagi <amyagi@gmail.com> wrote:
> On Fri, Aug 28, 2015 at 3:59 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> On Sat, Aug 22, 2015 at 08:44:48PM +0200, Pablo Neira Ayuso wrote:
>> [...]
>>> I'll wait for some little time just in case someone raises any
>>> concern.
>>
>> JFYI, I'll be passing up this patch to David via the nf tree soon.
>> Thanks.
>
> Thank you for pushing this forward.
>
> Akemi

Linux 4.2 was released without this patch. Please also backport it to
the 4.2 stable branch.

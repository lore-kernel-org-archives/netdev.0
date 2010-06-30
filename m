From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] vhost-net: add dhclient work-around from userspace
Date: Wed, 30 Jun 2010 14:30:14 -0700 (PDT)
Message-ID: <20100630.143014.134109550.davem@davemloft.net>
References: <20100628100807.GA30685@redhat.com>
	<20100629.003647.214219303.davem@davemloft.net>
	<20100629130439.GD3603@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arozansk@redhat.com, herbert.xu@redhat.com, quintela@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ykaul@redhat.com, markmc@redhat.com
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100629130439.GD3603@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 29 Jun 2010 16:04:39 +0300

> Since using the module involves updating the management tools
> as well, if we go down this route it will be much less painful
> for everyone to do push it upstream.

Ok, you can make your case to Patrick McHardy and if he'll merge
it into his netfilter GIT tree I guess I'll have to take it :)

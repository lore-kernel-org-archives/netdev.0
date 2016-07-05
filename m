From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 05 Jul 2016 02:38:33 -0700
Message-ID: <1467711513.19760.18.camel@perches.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
	 <1467706914.19760.16.camel@perches.com>
	 <CO2PR03MB218222BA0DD55CD967ED4F38BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Haiyang Zhang <haiyangz@microsoft.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>
To: Dexuan Cui <decui@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Cathy Avery <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB218222BA0DD55CD967ED4F38BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-05 at 09:31 +0000, Dexuan Cui wrote:

> > > +/* This is the address fromat of Hyper-V Sockets.
> > format
> I suppose you meant I should change=A0
> /* This is ...
> to=A0
> /*
> =A0 * This is ...
> I'll fix this.

No, I just meant fromat should =A0be format

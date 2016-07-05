From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 5 Jul 2016 10:46:50 +0000
Message-ID: <CO2PR03MB21820F417C74687E8F374A5EBF390@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
 <1467706914.19760.16.camel@perches.com>
 <CO2PR03MB218222BA0DD55CD967ED4F38BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
 <1467711513.19760.18.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: Joe Perches <joe@perches.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "apw@canonical.com" <apw@canonical.com>, "jasowang@redhat.com"
 <jasowang@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Cathy Avery
 <cavery@redhat.com>, KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1467711513.19760.18.camel@perches.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Tuesday, July 5, 2016 17:39
> To: Dexuan Cui <decui@microsoft.com>; davem@davemloft.net;
> gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; Vitaly Kuznetsov
> <vkuznets@redhat.com>; Cathy Avery <cavery@redhat.com>; KY Srinivasan
> <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>; Rolf Neugebauer
> <rolf.neugebauer@docker.com>
> Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> =

> On Tue, 2016-07-05 at 09:31 +0000, Dexuan Cui wrote:
> =

> > > > +/* This is the address fromat of Hyper-V Sockets.
> > > format
> > I suppose you meant I should change
> > /* This is ...
> > to
> > /*
> > =A0 * This is ...
> > I'll fix this.
> =

> No, I just meant fromat should =A0be format

Oh... Got it.  Thanks!
I'll fix the typo.

-- Dexuan

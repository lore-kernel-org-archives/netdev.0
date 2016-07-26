From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Mon, 25 Jul 2016 21:38:22 -0700 (PDT)
Message-ID: <20160725.213822.1745865660912873332.davem@davemloft.net>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.173701.1282720667210726281.davem@davemloft.net>
 <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, olaf@aepfle.de, gregkh@linuxfoundation.org,
 jasowang@redhat.com, dave.scott@docker.com, linux-kernel@vger.kernel.org,
 joe@perches.com, rolf.neugebauer@docker.com, netdev@vger.kernel.org,
 apw@canonical.com, devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
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

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 26 Jul 2016 03:09:16 +0000

> BTW, during the past month, at least 7 other people also reviewed
> the patch and gave me quite a few good comments, which have
> been addressed.

Correction: Several people gave coding style and simple corrections
to your patch.

Very few gave any review of the _SUBSTANCE_ of your changes.

And the one of the few who did, and suggested you build your
facilities using the existing S390 hypervisor socket infrastructure,
you brushed off _IMMEDIATELY_.

That drives me crazy.  The one person who gave you real feedback
you basically didn't consider seriously at all.

I know why you don't want to consider alternative implementations,
and it's because you guys have so much invested in what you've
implemented already.

But that's tough and not our problem.

And until this changes, yes, this submission will be stuck in the
mud and continue slogging on like this.

Sorry.

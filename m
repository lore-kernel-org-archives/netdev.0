From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Tue, 11 Aug 2015 11:07:08 -0700 (PDT)
Message-ID: <20150811.110708.2068514265578197752.davem@davemloft.net>
References: <1065657734.1253359.1439310306115.JavaMail.zimbra@savoirfairelinux.com>
	<20150811.103817.787813230853567028.davem@davemloft.net>
	<55CA38F7.4010105@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	linux@roeck-us.net, andrew@lunn.ch, sfeldma@gmail.com,
	jiri@resnulli.us
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CA38F7.4010105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 11 Aug 2015 11:03:35 -0700

> Put differently, my question is how do you value not rewriting
> history vs. breaking bisectability (by accident of course)?

I never will rewrite history, ever.

Too many people clone my tree and depend upon it.

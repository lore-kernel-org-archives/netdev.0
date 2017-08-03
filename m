From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 2/3] net: dsa: lan9303: define
 LAN9303_NUM_PORTS 3
Date: Thu, 3 Aug 2017 15:33:06 +0200
Message-ID: <20170803133306.GF15018@lunn.ch>
References: <20170801111439.1143-1-privat@egil-hjelmeland.no>
 <20170801111439.1143-3-privat@egil-hjelmeland.no>
 <201708011349.52529.jbe@pengutronix.de>
 <10b6b9fc-d2f9-1761-802f-724d9f6b3df1@egil-hjelmeland.no>
 <20170801132728.GA23157@lunn.ch>
 <2ab66f40-bbb4-151f-349c-8691e707e936@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juergen Borleis <jbe@pengutronix.de>, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2ab66f40-bbb4-151f-349c-8691e707e936@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Related question: If the driver does dsa_switch_alloc(3), can it then
> trust that all "port" params passed in DSA methods will be between
> 0 and 2?

Yes.

	Andrew

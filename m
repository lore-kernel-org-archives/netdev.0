From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] isdn: hisax: netjet requires VIRT_TO_BUS
Date: Fri, 15 Mar 2013 13:41:14 +0000
Message-ID: <201303151341.14311.arnd@arndb.de>
References: <201303151015.00746.arnd@arndb.de> <201303151229.52997.arnd@arndb.de> <20130315.083344.2224038988420448687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org, dhowells@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130315.083344.2224038988420448687.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 March 2013, David Miller wrote:
> The first usage seems reason, but the temtation is going to be quite
> strong to misuse to block out drivers when there is "no value" in
> spending time necessary to simply make them endian clean instead.

Right. I'll let someone else start that discussion then if they
really want to see that patch.

	Arnd

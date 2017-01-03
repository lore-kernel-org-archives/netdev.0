From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Wed, 04 Jan 2017 00:03:52 +0100
Message-ID: <10507790.a4n3csIkKa@wuerfel>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <3780968.pTT7cvIH4p@wuerfel> <1483484256.13649.13.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Karsten Keil <isdn@linux-pingi.de>,
 Jonathan Corbet <corbet@lwn.net>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1483484256.13649.13.camel@tiscali.nl>
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

On Tuesday, January 3, 2017 11:57:36 PM CET Paul Bolle wrote:
> On Tue, 2017-01-03 at 23:25 +0100, Arnd Bergmann wrote:
> > As far as I'm concerned, we are totally fine as long as there exists a
> > longterm supported kernel that has i4l in drivers/staging.
> 
> Or in drivers/isdn, right?

Right, I was assuming that we would first move it to staging and then
delete it, both at future points in time that we can debate. With the
existing longterm kernels that have i4l in drivers/isdn, the few remaining
users still have access to a supported kernel release until at least
2020.

	Arnd

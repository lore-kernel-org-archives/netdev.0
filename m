From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [RFC] econet: remove ancient bug ridden protocol
Date: Fri, 18 May 2012 05:23:01 +0100
Message-ID: <20120518042301.GA723@srcf.ucam.org>
References: <20120517205951.462d336f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Arnd Bergmann <arnd@arndb.de>,
	John Calixto <john.calixto@modsystems.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120517205951.462d336f@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 17, 2012 at 08:59:51PM -0700, Stephen Hemminger wrote:

> The ancient Econet protocol should go. Most of the bug fixes in recent
> years have been fixing security vulnerabilities. The hardware hasn't
> been made since 1981, it is only interesting as an archeological curiosity.

Pedantry - the hardware was introduced in 1981, it was still being made 
into at least the 90s. Still probably time for it to die, though.

-- 
Matthew Garrett | mjg59@srcf.ucam.org

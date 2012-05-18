From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] econet: remove ancient bug ridden protocol
Date: Fri, 18 May 2012 01:35:46 -0400 (EDT)
Message-ID: <20120518.013546.737313304742968032.davem@davemloft.net>
References: <20120517205951.462d336f@nehalam.linuxnetplumber.net>
	<20120518042301.GA723@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, paul.gortmaker@windriver.com, arnd@arndb.de,
	john.calixto@modsystems.com, xemul@parallels.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mjg59@srcf.ucam.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120518042301.GA723@srcf.ucam.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Garrett <mjg59@srcf.ucam.org>
Date: Fri, 18 May 2012 05:23:01 +0100

> On Thu, May 17, 2012 at 08:59:51PM -0700, Stephen Hemminger wrote:
> 
>> The ancient Econet protocol should go. Most of the bug fixes in recent
>> years have been fixing security vulnerabilities. The hardware hasn't
>> been made since 1981, it is only interesting as an archeological curiosity.
> 
> Pedantry - the hardware was introduced in 1981, it was still being made 
> into at least the 90s. Still probably time for it to die, though.

Patch applied with this pedantic adjustment :-)

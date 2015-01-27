From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH v2 0/2] Add ACPI support for NXP PN544
Date: Wed, 28 Jan 2015 00:29:11 +0100
Message-ID: <20150127232911.GC32667@ribalta.mp.intel.com>
References: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Berg Johannes <johannes.berg@intel.com>,
	Clement Perrochaud <clement.perrochaud@nxp.com>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Robert,

On Mon, Jan 26, 2015 at 01:13:35PM +0200, Robert Dolca wrote:
> This patch set introduces ACPI support for PN544.
> 
> gpio_set_value was replaced with gpio_set_value_cansleep in order
> to allow GPIO access that may sleep. This is particularelly useful
> when GPIO is accessed using busses like I2C, SPI, USB
> 
> Changes since v1:
> 	- Added cover letter
> 	- Removed debug define and Kconfig include
> 	- Minor fixes to patch subjects
> 
> Links to v1:
> 	- http://lkml.iu.edu/hypermail/linux/kernel/1501.1/00943.html
> 	- http://lkml.iu.edu/hypermail/linux/kernel/1501.1/00944.html
> 
> Robert Dolca (2):
>   NFC: PN544: GPIO access that may sleep
>   NFC: Add ACPI support for NXP PN544
Both patches applied, many thanks.

Cheers,
Samuel.

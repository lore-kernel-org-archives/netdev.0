From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] MIPS: OCTEON: Rename Kconfig CAVIUM_OCTEON_REFERENCE_BOARD
 to CAVIUM_OCTEON_SOC
Date: Wed, 22 May 2013 09:13:50 -0700
Message-ID: <519CEEBE.5020403@caviumnetworks.com>
References: <1369088378-13957-1-git-send-email-ddaney.cavm@gmail.com> <20130521220457.GF31836@blackmetal.musicnaut.iki.fi> <519BF01B.1010600@caviumnetworks.com> <20130522122232.GD10769@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>,
	David Daney <ddaney.cavm@gmail.com>,
	<linux-mips@linux-mips.org>, David Daney <david.daney@cavium.com>,
	<linux-ide@vger.kernel.org>, <linux-edac@vger.kernel.org>,
	<linux-i2c@vger.kernel.org>, <netdev@vger.kernel.org>,
	<spi-devel-general@lists.sourceforge.net>,
	<devel@driverdev.osuosl.org>, <linux-usb@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20130522122232.GD10769@linux-mips.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 05:22 AM, Ralf Baechle wrote:
> On Tue, May 21, 2013 at 03:07:23PM -0700, David Daney wrote:
>
>>>>   config USB_OCTEON_OHCI
>>>>   	bool "Octeon on-chip OHCI support"
>>>> -	depends on CPU_CAVIUM_OCTEON
>>>> +	depends on  CAVIUM_OCTEON_SOC
>>>
>>> Just a minor comment, here the extra whitespace after "depends on"
>>> could be eliminated.
>>>
>>
>> Good point.  I will regenerate the patch to correct this.
>
> I took care of that and queued the patch.
>

Can you take v2 instead?  It has the missing watchdog adjustment that is 
not in v1.

Thanks,
David Daney



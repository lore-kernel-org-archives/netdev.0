From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 0/8] netdev/MIPS: Improvements to octeon_mgmt Ethernet
 driver.
Date: Thu, 23 Aug 2012 08:35:44 +0200
Message-ID: <5035CF40.9040108@phrozen.org>
References: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com> <20120822.191654.1727215659090597701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120822.191654.1727215659090597701.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/08/12 04:16, David Miller wrote:
> From: David Daney <ddaney.cavm@gmail.com>
> Date: Tue, 21 Aug 2012 11:45:04 -0700
> 
>> From: David Daney <david.daney@cavium.com>
>>
>> Recent additions to the OCTEON SoC family have included enhancements
>> to the MIX (octeon_mgmt) Ethernet hardware.  These include:
>>
>> o 1Gig support (up from 100M).
>>
>> o Hardware timestamping for PTP.
>>
>> Here we add support for these two features as well as some ethtool
>> improvements and cleanup of the MAC address handling.
>>
>> Patch 1/8 is a prerequisite for the rest, and lives in the MIPS
>> architecture part of the tree.  Since octeon_mgmt devices are only
>> found in OCTEON SoCs we could merge the whole set via Ralf's tree, or
>> get Ralf to affix his Acked-by and have it go via the netdev tree.
> 
> You can send this all via the MIPS tree, and feel free to add my:
> 
> Acked-by: David S. Miller <davem@davemloft.net>


Thanks, queued for 3.7

	John

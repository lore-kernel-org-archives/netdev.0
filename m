From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 05 Nov 2015 11:29:20 -0500 (EST)
Message-ID: <20151105.112920.2123583342530330617.davem@davemloft.net>
References: <20151105.103126.148818796422971143.davem@davemloft.net>
	<20151105.110506.1901401372160830603.davem@davemloft.net>
	<20151105162831.GA5642@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, andy.shevchenko@gmail.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105162831.GA5642@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 5 Nov 2015 11:28:31 -0500

> On (11/05/15 11:05), David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Thu, 05 Nov 2015 10:31:26 -0500 (EST)
>> 
>> > I'll see if I can cook something up.
>> 
>> How does this look?
> 
> Looks good to me,
> 
> Do you want me to respin patch v7 with this? Or update ixgbe/i40e to use
> this later, after this goes in?

The intention is to let your patch go in as-is, then try and update
ixgbe/i40e later in net-next or similar.

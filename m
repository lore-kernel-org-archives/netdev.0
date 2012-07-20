From: David Miller <davem@davemloft.net>
Subject: Re: [trivial PATCH resend 1/2] ixgb: use PCI_VENDOR_ID_INTEL
Date: Fri, 20 Jul 2012 11:00:08 -0700 (PDT)
Message-ID: <20120720.110008.475112724617192181.davem@davemloft.net>
References: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
	<1342767729-17788-2-git-send-email-jdmason@kudzu.us>
	<1342768277.2616.22.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342768277.2616.22.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Jul 2012 00:11:17 -0700

> On Fri, 2012-07-20 at 00:02 -0700, Jon Mason wrote:
>> Use PCI_VENDOR_ID_INTEL from pci_ids.h instead of creating its own
>> vendor ID #define.
>> 
>> Signed-off-by: Jon Mason <jdmason@kudzu.us>
 ...
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

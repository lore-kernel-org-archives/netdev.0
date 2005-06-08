From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: allow controlling NAPI weight with sysfs
Date: Wed, 08 Jun 2005 14:24:45 -0700 (PDT)
Message-ID: <20050608.142445.126941321.davem@davemloft.net>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
	<20050602111437.1c492138@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@oss.sgi.com, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050602111437.1c492138@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 2 Jun 2005 11:14:37 -0700

> Simple interface to allow changing network device scheduling weight
> with sysfs. Please consider this for 2.6.12, since risk/impact is small.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Patch applied, thanks Stephen.

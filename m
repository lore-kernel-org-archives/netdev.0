From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [PATCH net-next] net: Lookup actual route when oif
 is VRF device
Date: Sun, 11 Oct 2015 22:27:09 +0800
Message-ID: <20151011142709.GD17528@wfg-t540p.sh.intel.com>
References: <201510060144.B0K1B1ZG%fengguang.wu@intel.com>
 <5612BD04.4040605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
	kbuild-all@01.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37198 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbbJKO1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Oct 2015 10:27:13 -0400
Content-Disposition: inline
In-Reply-To: <5612BD04.4040605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Oct 05, 2015 at 12:10:12PM -0600, David Ahern wrote:
> On 10/5/15 12:01 PM, kbuild test robot wrote:
> >Hi David,
> >
> >[auto build test ERROR on v4.3-rc4 -- if it's inappropriate base, please ignore]
> >
> 
> net-next patches can *not* be applied to Linus' tree. If you are going to
> run the build bot for patches submitted to netdev, please be sure to apply
> those patches to net-next tree.

OK. Hope these rules will work:

- "[PATCH net-next]" will be tested on net-next/master
- "[PATCH net]"      will be tested on net/master
- "[PATCH nf]"       will be tested on nf/master
- "[PATCH nf-next]"  will be tested on nf-next/master

Thanks,
Fengguang

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576	virtual
 functions
Date: Thu, 26 Mar 2009 14:05:07 +0100
Message-ID: <49CB7D83.10205@trash.net>
References: <20090325215248.28529.62295.stgit@lost.foo-projects.org> <20090325150322.40e0a1e6@nehalam> <49CAB13B.7070601@intel.com> <20090325.165847.234084422.davem@davemloft.net> <49CAD25F.4080705@intel.com> <20090326023343.GA8138@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Yu Zhao <yu.zhao@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63815 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601AbZCZNFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 09:05:19 -0400
In-Reply-To: <20090326023343.GA8138@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yu Zhao wrote:
> We do have some powerful tools for network device configuration, but they
> still can't cover the multi queue and SR-IOV NICs (also David Woodhouse's
> Solos DSL, etc.) configuration requirement. Unless someone improves the
> existing tools to support configuring these new hardware features, people
> would keep trying to use the sysfs which is the easiest way so far.

So what are these missing features in the existing interfaces?

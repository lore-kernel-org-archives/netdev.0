From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [ovs-dev] [PATCH net-next] NSH(Network Service Header)
 implementation
Date: Mon, 13 Jun 2016 12:11:14 +0200
Message-ID: <20160613121114.7c55fd14@griffin>
References: <1465205686-96724-1-git-send-email-yi.y.yang@intel.com>
	<CAOrHB_DF+LvRyJAOu6h=ofbf-T-Q85FutsFZ118FhsCsLsVBCg@mail.gmail.com>
	<20160612075349.GA35971@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
	dev@openvswitch.org
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965022AbcFMKLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 06:11:18 -0400
In-Reply-To: <20160612075349.GA35971@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Jun 2016 15:53:50 +0800, Yang, Yi wrote:
> Will use net device after those patches are merged into net-next, It
> seems current net device implementation in net-next doesn't include it,

The current kernel should have everything that's needed for VXLAN-GPE
support.

> do you mean this one
> "http://article.gmane.org/gmane.network.openvswitch.devel/64799"?

This patchset is absolutely needed for ovs to support new VXLAN
features, including VXLAN-GPE.

 Jiri

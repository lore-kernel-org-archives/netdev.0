From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 25 Mar 2009 20:12:19 -0700 (PDT)
Message-ID: <20090325.201219.98810772.davem@davemloft.net>
References: <49CAB13B.7070601@intel.com>
	<20090325.165847.234084422.davem@davemloft.net>
	<49CAD25F.4080705@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58061
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751436AbZCZDMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:12:31 -0400
In-Reply-To: <49CAD25F.4080705@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 25 Mar 2009 17:54:55 -0700

> Since the issue isn't the igbvf driver there is no reason for it to
> be held up.

I disagree, I think both cases should be fixed.

Just because we do something already never means that it's
ok to proliferate the mistake further.

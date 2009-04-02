From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] igb: increase delay for copper link setup
Date: Thu, 02 Apr 2009 01:00:02 -0700 (PDT)
Message-ID: <20090402.010002.78381567.davem@davemloft.net>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
	<20090401063837.3046.221.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41760
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755647AbZDBIAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:00:13 -0400
In-Reply-To: <20090401063837.3046.221.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 31 Mar 2009 23:38:38 -0700

> Increase the delay for copper phy init from 15ms to 100ms.  This is to
> address issues seen in which ethtool -t was failing in some cases on 82576
> based adapters.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

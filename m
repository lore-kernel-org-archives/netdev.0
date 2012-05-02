From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 6/8] ixgbe: add syfs interface for to export read
 only driver information
Date: Wed, 02 May 2012 04:51:27 -0400 (EDT)
Message-ID: <20120502.045127.1981810991569714337.davem@davemloft.net>
References: <1335862269-28914-7-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120501.100241.1409452912879198250.davem@davemloft.net>
	<1335948107.2656.33.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab2EBIve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 04:51:34 -0400
In-Reply-To: <1335948107.2656.33.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 02 May 2012 01:41:47 -0700

> So the other two patches (patch 4 & 5 in the series) should be fine
> since they integrate hwmon interface like how Ben Hutchings has done
> with other drivers and do not add any sysfs, correct?

Correct.

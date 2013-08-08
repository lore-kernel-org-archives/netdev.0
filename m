From: Joe Perches <joe@perches.com>
Subject: Re: Preferred method for configuration
Date: Wed, 07 Aug 2013 22:41:20 -0700
Message-ID: <1375940480.2424.135.camel@joe-AO722>
References: <52032D5E.6070307@hhi.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59119 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753335Ab3HHFlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 01:41:21 -0400
In-Reply-To: <52032D5E.6070307@hhi.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 07:32 +0200, Thomas Martitz wrote:
> Hello,
> 
> I'm developing a NIC driver and currently export some custom 
> configuration settings and actions (e.g. enabling a loopback mode) via 
> sysfs.

Is there some reason you don't want to use ethtool?

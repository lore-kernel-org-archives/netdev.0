From: David Miller <davem@davemloft.net>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 12:23:59 -0500 (EST)
Message-ID: <20140221.122359.1820499999845408491.davem@davemloft.net>
References: <20140221130553.GE2870@minipsycho.orion>
	<20140221143114.GC25406@gmail.com>
	<20140221144827.GG2870@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tobias@waldekranz.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbaBURYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 12:24:00 -0500
In-Reply-To: <20140221144827.GG2870@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 21 Feb 2014 15:48:27 +0100

> Would not it be better to make DSA better in order to achieve your goal?

+1

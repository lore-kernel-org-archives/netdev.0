From: David Miller <davem@davemloft.net>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Wed, 12 Mar 2008 20:41:45 -0700 (PDT)
Message-ID: <20080312.204145.202573599.davem@davemloft.net>
References: <20080311165253.GG26963@solarflare.com>
	<65634d660803111648l15c4d653t52b4fc9e8dfa531d@mail.gmail.com>
	<20080312151051.GI26963@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse.brandeburg@intel.com, maxk@qualcomm.com,
	netdev@vger.kernel.org, rostedt@goodmis.org, mingo@elte.hu
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751291AbYCMDlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 23:41:37 -0400
In-Reply-To: <20080312151051.GI26963@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Mar 2008 15:10:52 +0000

> It's not supported, but it's on David Miller's to-do list[1].
...
> 1. http://vger.kernel.org/~davem/net_todo.html

That copy of the TODO list is out of date, and we fully
support multiqueue RX devices, it's a device driver level
issue at this point.

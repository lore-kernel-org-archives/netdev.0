From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 31/42] dvb: update network device to current API
Date: Wed, 07 Jan 2009 18:02:58 -0800 (PST)
Message-ID: <20090107.180258.189594222.davem@davemloft.net>
References: <20090107003316.784424362@vyatta.com>
	<20090107003348.828888483@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: v4l-dvb-maintainer@linuxtv.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756358AbZAHCC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 21:02:56 -0500
In-Reply-To: <20090107003348.828888483@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 06 Jan 2009 16:33:47 -0800

> Use internal network_device_stats that exist in network device and
> net_device_ops. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

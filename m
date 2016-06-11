From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,v3] openvswitch: Add packet truncation support.
Date: Fri, 10 Jun 2016 17:58:16 -0700 (PDT)
Message-ID: <20160610.175816.2088684003410275959.davem@davemloft.net>
References: <1465584573-58583-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbcFKA6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 20:58:20 -0400
In-Reply-To: <1465584573-58583-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Fri, 10 Jun 2016 11:49:33 -0700

> The patch adds a new OVS action, OVS_ACTION_ATTR_TRUNC, in order to
> truncate packets. A 'max_len' is added for setting up the maximum
> packet size, and a 'cutlen' field is to record the number of bytes
> to trim the packet when the packet is outputting to a port, or when
> the packet is sent to userspace.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied.

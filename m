From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: proc: revert proc_net_fops_create/proc_net_remove
 removal
Date: Fri, 08 Mar 2013 12:46:38 -0500 (EST)
Message-ID: <20130308.124638.857825798968866326.davem@davemloft.net>
References: <20130308135635.GA1078@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934459Ab3CHRqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:46:39 -0500
In-Reply-To: <20130308135635.GA1078@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 8 Mar 2013 16:56:35 +0300

> Revert the following patches:

I'm not going back and forth again on this, you guys need to fight it
out.

I personally thought the removal was fine, and the extra interfaces
were just clutter.  Justifying it just to hide init_net.proc_net is
a scarecrow at best.

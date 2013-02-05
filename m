From: David Miller <davem@davemloft.net>
Subject: [MERGE] net into net-next
Date: Tue, 05 Feb 2013 14:20:16 -0500 (EST)
Message-ID: <20130205.142016.1293426562457111667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785Ab3BETUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:20:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just merged net into net-next.

Most of the conflicts were trivial, except perhaps the iwlwifi one
which is dealing with a revert that happened on the 'net' side.

John please double-check my work.  It's ironic that this happened
because you did a wireless mainline merge the last time you asked me
to pull into net-next exactly to avoid conflicts in this piece of code
:-)

Thanks.

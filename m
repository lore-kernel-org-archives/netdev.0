From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next] sunvnet: fix null pointer deref and crash
 recovery
Date: Tue, 27 Jan 2015 00:25:47 -0800 (PST)
Message-ID: <20150127.002547.408138803887244028.davem@davemloft.net>
References: <54C6A976.4060502@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbA0IZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:25:48 -0500
In-Reply-To: <54C6A976.4060502@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 26 Jan 2015 15:54:14 -0500

> These patches fix an incorrect ordering in releasing ring data, clear pending
> tx buffers on a reset, and make the sunvnet driver more reliable when remote
> systems crash during active transmits.

Series applied, thanks David.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sk-filter: Add ability to get socket filter
 program
Date: Wed, 31 Oct 2012 13:45:32 -0400 (EDT)
Message-ID: <20121031.134532.1861747412920375129.davem@davemloft.net>
References: <508AC533.4000809@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759532Ab2JaRpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:45:35 -0400
In-Reply-To: <508AC533.4000809@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't only add this to asm-generic, you must add the new
option to all the arch specific headers that need it too.

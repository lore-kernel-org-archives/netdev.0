From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] rhashtable updates
Date: Fri, 20 Feb 2015 17:38:28 -0500 (EST)
Message-ID: <20150220.173828.383422478876924054.davem@davemloft.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, johunt@akamai.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbbBTWib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:38:31 -0500
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 20 Feb 2015 00:53:36 +0100

> Daniel Borkmann (3):
>   rhashtable: don't test for shrink on insert, expansion on delete
>   rhashtable: better high order allocation attempts
>   rhashtable: allow to unload test module

Series applied, thanks Daniel.

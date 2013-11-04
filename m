From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] crc/csum follow-ups
Date: Mon, 04 Nov 2013 15:27:29 -0500 (EST)
Message-ID: <20131104.152729.214146036425775143.davem@davemloft.net>
References: <cover.1383580331.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab3KDU1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 15:27:34 -0500
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  4 Nov 2013 17:10:24 +0100

> Daniel Borkmann (3):
>   net: checksum: fix warning in skb_checksum
>   lib: crc32: conditionally resched when running testcases
>   lib: crc32: reduce number of tests for crc32{,c}_combine

Series applied, thanks for responding to this so quickly Daniel.

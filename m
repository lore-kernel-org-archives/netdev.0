From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ARM: net: bpf_jit_32: add VLAN
 instructions for BPF JIT
Date: Tue, 13 Nov 2012 18:21:37 -0500 (EST)
Message-ID: <20121113.182137.290728881555855814.davem@davemloft.net>
References: <20121108013101.GB23143@thinkbox>
	<50A2D114.8080306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: mgherzan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab2KMXVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 18:21:38 -0500
In-Reply-To: <50A2D114.8080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mircea Gherzan <mgherzan@gmail.com>
Date: Wed, 14 Nov 2012 00:00:36 +0100

> Am 08.11.2012 02:31, schrieb Daniel Borkmann:
>> This patch is a follow-up for patch "net: filter: add vlan tag access"
>> to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.
>> 
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
 ...
> Acked-by: Mircea Gherzan <mgherzan@gmail.com>

Applied, thanks again.

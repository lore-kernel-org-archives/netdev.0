From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/14] mlxsw: Implement basic FIB offload and
 router interfaces
Date: Mon, 04 Jul 2016 18:25:34 -0700 (PDT)
Message-ID: <20160704.182534.173186350057964120.davem@davemloft.net>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932727AbcGEBZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 21:25:38 -0400
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  4 Jul 2016 08:23:03 +0200

> Introduce LPM trees management including virtual router management for HW.
> Implement basic FIB offloading using switchdev FIB objects. For now only support
> local routes and direct routes (next-hop support will be introduced in
> a follow-up patchset).
> 
> Introduce router interfaces in patches 10-14.

Series applied, thanks.

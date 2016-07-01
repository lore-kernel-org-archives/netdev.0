From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/42] mlxsw: Implement IPV4 unicast routing
Date: Fri, 01 Jul 2016 15:27:16 -0400 (EDT)
Message-ID: <20160701.152716.1930131608670556376.davem@davemloft.net>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
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
Received: from shards.monkeyblade.net ([149.20.54.216]:42477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbcGAT1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 15:27:55 -0400
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  1 Jul 2016 16:04:28 +0200

> This patchset enables IPv4 unicast routing in the Mellanox Spectrum
> ASIC switch driver. The basic dependencies are already present in
> the kernel and used by rocker.

Please split this up into smaller segments (~15 patches, max) and
resubmit.

A 42 patch series present an unreasonable burdon for reviewers.

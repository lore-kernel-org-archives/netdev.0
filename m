From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Octeon: Fix logic for waking octoen ethernet tx queue.
Date: Tue, 22 Dec 2015 00:30:56 -0500 (EST)
Message-ID: <20151222.003056.307643520622626460.davem@davemloft.net>
References: <1450299572-11012-1-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
	<567882D2.1020406@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luuk.Paulussen@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbbLVFbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 00:31:00 -0500
In-Reply-To: <567882D2.1020406@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Date: Mon, 21 Dec 2015 22:53:06 +0000

> The patch is a bugfix for an ethernet driver in the staging dir.

Changes to things under drivers/staging get submitted to the
staging maintainer, not here.

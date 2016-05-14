From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on recent PCIe chips
Date: Sat, 14 May 2016 15:02:12 -0400 (EDT)
Message-ID: <20160514.150212.940960921736176536.davem@davemloft.net>
References: <1463222485-4513-1-git-send-email-ard.biesheuvel@linaro.org>
	<CAKv+Gu8uiR0uLpbvJ+K8xRVXt=-bsTAuCrL0jicoPbMfE5PzWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	ricardo.salveti@linaro.org, leif.lindholm@linaro.org,
	graeme.gregory@linaro.org, amit.kucheria@linaro.org,
	nic_swsd@realtek.com
To: ard.biesheuvel@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760AbcENTCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 15:02:18 -0400
In-Reply-To: <CAKv+Gu8uiR0uLpbvJ+K8xRVXt=-bsTAuCrL0jicoPbMfE5PzWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 14 May 2016 14:08:54 +0200

> The reordering above is actually unnecessary, it crept in inadvertently.

Then post a new version of the patch without it.

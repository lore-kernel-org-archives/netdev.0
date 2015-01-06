From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: eth: xgene: change APM X-Gene SoC platform
 ethernet to support ACPI
Date: Tue, 06 Jan 2015 14:46:11 -0500 (EST)
Message-ID: <20150106.144611.682542061306728720.davem@davemloft.net>
References: <CAL85gmCGK54yK3sThVhGsatMVUS8+76LRwdDt4w9PUfppMJ3og@mail.gmail.com>
	<20150105.231054.790363276763745624.davem@davemloft.net>
	<CAL85gmDybxCB59UcpFm3NRR7bxG-_1xsmXAs3oehOujEoetiog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patches@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fkan@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932463AbbAFTqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:46:14 -0500
In-Reply-To: <CAL85gmDybxCB59UcpFm3NRR7bxG-_1xsmXAs3oehOujEoetiog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng Kan <fkan@apm.com>
Date: Tue, 6 Jan 2015 11:30:46 -0800

> the platform, I am not sure how to recreate this.

Build allmodconfig on x86-64, the most commonly tested build.

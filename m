From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to
 shared header
Date: Tue, 13 Aug 2013 14:14:28 -0700 (PDT)
Message-ID: <20130813.141428.649852402463720916.davem@davemloft.net>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
	<1376069482-16951-2-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, broonie@linaro.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141Ab3HMVO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:14:29 -0400
In-Reply-To: <1376069482-16951-2-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Fri,  9 Aug 2013 18:31:22 +0100

> From: Mark Brown <broonie@linaro.org>
> 
> Ensure that the definition of ax88172a_info matches the declaration seen
> by users and silence sparse warnings about symbols without declarations
> in the global namespace by moving the declaration into the shared header
> asix.h.
> 
> Signed-off-by: Mark Brown <broonie@linaro.org>

Applied.

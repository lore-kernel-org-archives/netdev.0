From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 1/3] net: dsa: Use devm_ prefixed allocations
Date: Wed, 30 Sep 2015 14:45:20 -0700
Message-ID: <560C57F0.1090804@gmail.com>
References: <560B9B74.3080905@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34026 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbbI3Vpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:45:36 -0400
In-Reply-To: <560B9B74.3080905@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/09/15 01:21, Neil Armstrong wrote:
> To simplify and prevent memory leakage when unbinding, use
> the devm_ memory allocation calls.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

For this entire series, on BCM7445 (using bcm_sf2)

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian

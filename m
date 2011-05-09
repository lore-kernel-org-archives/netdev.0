From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] PCH_GbE : Fixed the issue of collision detection
Date: Mon, 09 May 2011 11:55:29 -0700 (PDT)
Message-ID: <20110509.115529.59687897.davem@davemloft.net>
References: <4DC3EF5F.1030306@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomoya-linux@dsn.okisemi.com,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, andrew.chih.howe.khor@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DC3EF5F.1030306@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Fri, 06 May 2011 21:53:51 +0900

> The collision detection setting was invalid.
> When collision occurred, because data was not resenr, 
> there was an issue to which a transmitting throughput falls.
> 
> This patch enables the collision detection.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied.

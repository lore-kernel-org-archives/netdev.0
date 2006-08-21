From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/7] ieee80211: Add IEEE80211_API_VERSION macro
Date: Mon, 21 Aug 2006 14:02:51 +0100
Message-ID: <20060821130251.GA26513@infradead.org>
References: <20060821033322.GA4793@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:7108 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030443AbWHUNDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 09:03:15 -0400
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <20060821033322.GA4793@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 11:33:22AM +0800, Zhu Yi wrote:
> Add IEEE80211_API_VERSION macro so that drivers are able to check it
> during compile time. This feature is useful to make backward IEEE80211
> compatibilities for wireless drivers.

NACK.


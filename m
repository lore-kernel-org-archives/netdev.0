From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/5] Add support for Geneve udp port offload
Date: Wed, 16 Dec 2015 10:59:34 -0500 (EST)
Message-ID: <20151216.105934.520978894635824817.davem@davemloft.net>
References: <1450124481-206978-1-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: anjali.singhai@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbbLPP7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 10:59:36 -0500
In-Reply-To: <1450124481-206978-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>
Date: Mon, 14 Dec 2015 12:21:16 -0800

> This patch series adds new ndo ops for Geneve add/del port, so as
> to help offload Geneve tunnel functionalities such as RX checksum,
> RSS, filters etc.

Series applied, thanks.

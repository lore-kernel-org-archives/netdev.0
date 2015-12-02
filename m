From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
 2015-12-02
Date: Wed, 02 Dec 2015 16:45:26 -0500 (EST)
Message-ID: <20151202.164526.1487154551042849320.davem@davemloft.net>
References: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbbLBVp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 16:45:29 -0500
In-Reply-To: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  2 Dec 2015 04:30:53 -0800

> This series contains updates to ixgbe and ixgbevf only.

I've marked this "changed requested" pending resolution of the ipv6
header parsing feedback Alexander gave.

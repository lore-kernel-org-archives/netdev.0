From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 00:43:02 -0700 (PDT)
Message-ID: <20120626.004302.1065943933933136878.davem@davemloft.net>
References: <1340695993-1911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab2FZHnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:43:03 -0400
In-Reply-To: <1340695993-1911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't put things like "[3.4]" unquoted into the CC: list, that's
not kosher and vger rejected it.

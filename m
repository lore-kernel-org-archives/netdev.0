From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: move is_vlan_dev into public header file (v2)
Date: Wed, 25 May 2011 17:56:17 -0400 (EDT)
Message-ID: <20110525.175617.164365611592866156.davem@davemloft.net>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
	<1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
	<1306261869-7276-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362Ab1EYV5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:57:46 -0400
In-Reply-To: <1306261869-7276-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 24 May 2011 14:31:08 -0400

> Migrate is_vlan_dev() to if_vlan.h so that core networkig can use it
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.

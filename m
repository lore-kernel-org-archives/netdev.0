From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: request native mode each time the
 card is reset
Date: Thu, 21 Jul 2011 21:33:05 -0700 (PDT)
Message-ID: <20110721.213305.1640365097500311889.davem@davemloft.net>
References: <1311141153-13272-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab1GVEdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:33:08 -0400
In-Reply-To: <1311141153-13272-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 20 Jul 2011 11:22:33 +0530

> Currently be3-native mode is requested only in probe(). It must be requested, each time the card is reset either after an EEH error or after
> sleep/hibernation.
> Also, the be_cmd_check_native_mode() is better named be_cmd_req_native_mode()
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Fix to avoid hardware workaround when not
 needed
Date: Tue, 16 Jul 2013 13:03:58 -0700 (PDT)
Message-ID: <20130716.130358.711125572475101678.davem@davemloft.net>
References: <458bdd84-53ce-489e-b134-f435c5fd6a50@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196Ab3GPUD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:03:59 -0400
In-Reply-To: <458bdd84-53ce-489e-b134-f435c5fd6a50@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Tue, 16 Jul 2013 12:44:02 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Hardware workaround requesting hardware to skip vlan insertion is necessary
> only when umc or qnq is enabled. Enabling this workaround in other scenarios
> could cause controller to stall.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] be2net: log link status
Date: Thu, 30 Apr 2015 16:36:34 -0400 (EDT)
Message-ID: <20150430.163634.1663619851601573876.davem@davemloft.net>
References: <20150429.150125.1929181206333250804.davem@davemloft.net>
	<1430387989-3552-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbbD3Ugg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:36:36 -0400
In-Reply-To: <1430387989-3552-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 30 Apr 2015 11:59:49 +0200

> The driver unlike other drivers does not log link state changes. It's
> better for an user when asynchronous link states are logged to the system
> log.
> 
> v3: Changes from v2 discarded as "not necessary"
> 
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.

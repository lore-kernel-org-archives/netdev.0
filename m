From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/14] batman-adv: refactoring API: find generalized
 name for bat_ogm_update_mac callback
Date: Wed, 09 May 2012 20:42:11 -0400 (EDT)
Message-ID: <20120509.204211.1682541114536655093.davem@davemloft.net>
References: <1336561976-16088-1-git-send-email-ordex@autistici.org>
	<1336561976-16088-10-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	lindner_marek@yahoo.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756628Ab2EJAoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 20:44:19 -0400
In-Reply-To: <1336561976-16088-10-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed,  9 May 2012 13:12:51 +0200

> +	/* (re-)init mac addresses of the protocol information
> +	 * belonging to this hard-interface */

Needs to be:

	/* (re-)init mac addresses of the protocol information
	 * belonging to this hard-interface
	 */

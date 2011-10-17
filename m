From: David Miller <davem@davemloft.net>
Subject: Re: EHEA updates
Date: Mon, 17 Oct 2011 19:06:13 -0400 (EDT)
Message-ID: <20111017.190613.1726682428123083243.davem@davemloft.net>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anton@samba.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524Ab1JQXGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:06:24 -0400
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Fri, 14 Oct 2011 12:30:57 -0300

> This is a rebase of Anton's patches on top of net-next HEAD, commit
> 7ae60b3. Besides the conflicts with the latest patches, some trivia were
> fixed as suggested.
> 
> Ben Hutchings' suggestions about doing packet split and NAPI fixes were
> taken into consideration, but not done on this round.
> 
> The result was tested between two LPARs and also using a switch, with
> ICMP and TCP tests.

Nice work, all applied, thanks.

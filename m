From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/2] Minor documentation updates for ip-related
 tunables
Date: Mon, 04 Jul 2011 19:27:46 -0700 (PDT)
Message-ID: <20110704.192746.2072974278032491252.davem@davemloft.net>
References: <20110705015718.32777815DBB1@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: makc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983Ab1GEC2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 22:28:00 -0400
In-Reply-To: <20110705015718.32777815DBB1@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Matveev <makc@redhat.com>
Date: Tue,  5 Jul 2011 11:57:18 +1000 (EST)

> Confusion about the way SCTP uses its rmem and wmem tunables
> prompted a documentation revision.
> 
> v2: incorporate suggestions by Shan Wei and Neil Horman.
> 
> Max Matveev (2):
>   Update description of net.sctp.sctp_rmem and net.sctp.sctp_wmem tunables
>   Update documented default values for various TCP/UDP tunables

Applied to net-next-2.6, thanks.

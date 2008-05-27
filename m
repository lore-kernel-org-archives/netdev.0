From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [TCP][DCCP]: Consolidate duplicate code which does
 RFC3390 conversion
Date: Tue, 27 May 2008 06:37:45 -0700 (PDT)
Message-ID: <20080527.063745.105720366.davem@davemloft.net>
References: <1211877167-10995-6-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-7-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-8-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41010
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757576AbYE0Nht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 09:37:49 -0400
In-Reply-To: <1211877167-10995-8-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:47 +0100

> This patch consolidates the code common to TCP and CCID-2:
> 
>  * TCP uses RFC 3390 in a packet-oriented manner (tcp_input.c) and
>  * CCID-2 uses RFC 3390 in packet-oriented manner (RFC 4341).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Depends upon hctx prefix changes which will not be applied, please
repsin.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 05/12] netxen: refactor tso code
Date: Mon, 27 Jul 2009 10:34:03 -0700 (PDT)
Message-ID: <20090727.103403.253183465.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-6-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753364AbZG0Rd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:33:56 -0400
In-Reply-To: <1248674867-18821-6-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 23:07:40 -0700

> o move all tso / checksum offload code into netxen_tso_check().
> o optimize the tso header copy into simple loop.
> o clean up unnecessary unions from cmd_desc_type0 struct.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.

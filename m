From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 2/3] netxen: refactor netxen_recv_context struct
Date: Tue, 28 Apr 2009 23:00:56 -0700 (PDT)
Message-ID: <20090428.230056.58761276.davem@davemloft.net>
References: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
	<1240968551-13186-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45539
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752374AbZD2GBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 02:01:02 -0400
In-Reply-To: <1240968551-13186-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue, 28 Apr 2009 18:29:10 -0700

> o move related fields into netxen_recv_context struct.
> o allocate rx buffer and descriptor rings dynamically.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.

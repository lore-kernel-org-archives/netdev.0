From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: reduce memory footprint
Date: Mon, 26 Jan 2009 12:35:27 -0800 (PST)
Message-ID: <20090126.123527.249582395.davem@davemloft.net>
References: <1232856179-15153-1-git-send-email-dhananjay@netxen.com>
	<1232856179-15153-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35593
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750988AbZAZUfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:35:25 -0500
In-Reply-To: <1232856179-15153-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat, 24 Jan 2009 20:02:59 -0800

> o reduce rx ring size from 8192 to 4096.
> o cut down old huge lro buffers.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Also applied, thanks.

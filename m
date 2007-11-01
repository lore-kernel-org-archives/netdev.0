From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] Move the sock_copy() from the header
Date: Thu, 01 Nov 2007 00:30:02 -0700 (PDT)
Message-ID: <20071101.003002.116901614.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<47288629.3010200@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35673
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753922AbXKAHaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:30:03 -0400
In-Reply-To: <47288629.3010200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:42:01 +0300

> The sock_copy() call is not used outside the sock.c file,
> so just move it into a sock.c
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6][NET-2.6.24] Introduce the seq_open_private()
Date: Wed, 10 Oct 2007 02:32:52 -0700 (PDT)
Message-ID: <20071010.023252.98748595.davem@davemloft.net>
References: <470BA351.3070208@openvz.org>
	<470BA3DA.6050905@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752356AbXJJJcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:32:50 -0400
In-Reply-To: <470BA3DA.6050905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 09 Oct 2007 19:52:58 +0400

> This function allocates the zeroed chunk of memory and
> call seq_open(). The __seq_open_private() helper returns
> the allocated memory to make it possible for the caller
> to initialize it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, nice cleanup Pavel.

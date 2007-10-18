From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] Remove no longer needed ->equal callback
Date: Wed, 17 Oct 2007 19:48:03 -0700 (PDT)
Message-ID: <20071017.194803.38714064.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C52B.3030100@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762418AbXJRCsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:48:05 -0400
In-Reply-To: <4714C52B.3030100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 18:05:31 +0400

> Since this callback is used to check for conflicts in
> hashtable when inserting a newly created frag queue, we can
> do the same by checking for matching the queue with the 
> argument, used to create one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

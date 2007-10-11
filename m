From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1][NET] : Fix dev_put() and dev_hold() comments
Date: Wed, 10 Oct 2007 21:18:35 -0700 (PDT)
Message-ID: <20071010.211835.27946693.davem@davemloft.net>
References: <20071002143733.282284314@frecb000701.frec.bull.fr>
	<20071002143809.936848538@frecb000701.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbXJKESc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:18:32 -0400
In-Reply-To: <20071002143809.936848538@frecb000701.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 02 Oct 2007 16:37:34 +0200

> Trivial fix: Swap comments for dev_put() and dev_hold() to get them 
> at the right place.
> Typo introduced by 4fa57c9ea9f36f9ca852f3a88ca5d2f1aebbc960.
> 
> Signed-of-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks.

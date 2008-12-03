From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: Fix a potential NULL pointer dereference
Date: Wed, 03 Dec 2008 00:37:16 -0800 (PST)
Message-ID: <20081203.003716.129097109.davem@davemloft.net>
References: <20081202032755.17851.61631.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751015AbYLCNYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 08:24:24 -0500
In-Reply-To: <20081202032755.17851.61631.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 01 Dec 2008 22:27:55 -0500

> Fix a potential NULL pointer dereference seen when trying to remove a static
> label configuration with an invalid address/mask combination.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied to net-2.6, thanks Paul.

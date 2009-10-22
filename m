From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 21 Oct 2009 17:19:40 -0700 (PDT)
Message-ID: <20091021.171940.193722199.davem@davemloft.net>
References: <4ADF4CBD.90104@Sun.COM>
	<20091021.160923.26786943.davem@davemloft.net>
	<4ADF992D.40507@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce.Yu@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574AbZJVATS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 20:19:18 -0400
In-Reply-To: <4ADF992D.40507@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joyce Yu <Joyce.Yu@Sun.COM>
Date: Wed, 21 Oct 2009 16:28:45 -0700

> It was in the patch. Was an empty line needed after the body of the
> explanation? I will send out one with an empty line between body of
> the explanation and signed-off-by tag.

It should be of the form:

--------------------
Subject: Summary description of patch.

Full patch description.

Signed-off-by: ...

The patch.
--------------------

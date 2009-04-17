From: David Miller <davem@davemloft.net>
Subject: Re: [patch]handle EPERM in pegasus
Date: Fri, 17 Apr 2009 01:40:26 -0700 (PDT)
Message-ID: <20090417.014026.66554286.davem@davemloft.net>
References: <200904161323.26443.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petkan@users.sourceforge.net
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbZDQIke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:40:34 -0400
In-Reply-To: <200904161323.26443.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 16 Apr 2009 13:23:25 +0200

> EPERM means that disconnect() is runnung. It should be treated like
> ENODEV
> 
> Signed-off-by: Oliver Neukum <oliver@neukum.org>

Applied.

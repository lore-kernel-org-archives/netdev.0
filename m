From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] stmmac: make function tables const
Date: Sat, 16 Oct 2010 11:57:12 -0700 (PDT)
Message-ID: <20101016.115712.102564577.davem@davemloft.net>
References: <20101013175031.41c29349@nehalam>
	<20101013175125.6f6a64db@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, deepak.sikri@st.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35285
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753578Ab0JPS4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:56:50 -0400
In-Reply-To: <20101013175125.6f6a64db@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 13 Oct 2010 17:51:25 -0700

> These tables only contain function pointers.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Remove redundant unlikely()
Date: Fri, 10 Dec 2010 14:57:50 -0800 (PST)
Message-ID: <20101210.145750.58419192.davem@davemloft.net>
References: <1291906222-575-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752067Ab0LJW5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 17:57:22 -0500
In-Reply-To: <1291906222-575-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  9 Dec 2010 15:50:22 +0100

> IS_ERR() already implies unlikely(), so it can be omitted here.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.

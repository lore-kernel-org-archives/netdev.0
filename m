From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers net: Fix declaration ordering in inline
 functions.
Date: Mon, 28 Mar 2011 22:27:38 -0700 (PDT)
Message-ID: <20110328.222738.115934586.davem@davemloft.net>
References: <1301282119-2887-1-git-send-email-balajig81@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: balajig81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752347Ab1C2F2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 01:28:16 -0400
In-Reply-To: <1301282119-2887-1-git-send-email-balajig81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "G.Balaji" <balajig81@gmail.com>
Date: Mon, 28 Mar 2011 08:45:19 +0530

> The correct usage should be "static inline void" instead of "static void inline"
> 
> Signed-off-by: G.Balaji <balajig81@gmail.com>

Applied.

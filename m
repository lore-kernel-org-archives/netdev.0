From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][7/7] inter address family ipsec tunnel
Date: Thu, 30 Nov 2006 17:05:30 -0800 (PST)
Message-ID: <20061130.170530.94074706.davem@davemloft.net>
References: <20061124143917.604095d7.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:28583
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031674AbWLABF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 20:05:27 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061124143917.604095d7.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 24 Nov 2006 14:39:17 +0900

> ip6_append_data should refer mtu of "dst"
> because of the same reasone of the previous patch.

Same comments of mine for ipv4 side of this change also apply here.

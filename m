From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] [IPV6] ADDRCONF: Preparation for configurable
 address selection policy with ifindex.
Date: Tue, 30 Oct 2007 00:42:06 -0700 (PDT)
Message-ID: <20071030.004206.61460735.davem@davemloft.net>
References: <20071030.145237.68878443.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753056AbXJ3Hm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 03:42:29 -0400
In-Reply-To: <20071030.145237.68878443.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 30 Oct 2007 14:52:37 +0900 (JST)

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

What is the substance of this change?  Please add a description of
this to the changelog entry as currently the description is far too
brief and vague.

Even saying simply that the change allows the interface index
to be passed into the address selection routines would be
a great improvement.

Thank you.

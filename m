From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] Hide the net_ns kmem cache
Date: Thu, 01 Nov 2007 00:47:05 -0700 (PDT)
Message-ID: <20071101.004705.84607426.davem@davemloft.net>
References: <4728D54F.2080208@openvz.org>
	<4728D867.8050207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755027AbXKAHrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:47:06 -0400
In-Reply-To: <4728D867.8050207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 22:32:55 +0300

> This cache is only required to create new namespaces,
> but we won't have them in CONFIG_NET_NS=n case.
> 
> Hide it under the appropriate ifdef.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

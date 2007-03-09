From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1][UDP]: Use __skb_pull since we have checked it
 won't fail with pskb_may_pull
Date: Fri, 09 Mar 2007 13:52:14 -0800 (PST)
Message-ID: <20070309.135214.89037114.davem@davemloft.net>
References: <39e6f6c70703090607h29e1a0d0lef770fdc02b16eab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933380AbXCIVwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 16:52:14 -0500
In-Reply-To: <39e6f6c70703090607h29e1a0d0lef770fdc02b16eab@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 9 Mar 2007 11:07:50 -0300

> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-2.6.22, thanks.

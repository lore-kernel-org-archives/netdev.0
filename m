From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix tx ring size in ethtool -g
Date: Thu, 16 Apr 2009 17:58:05 -0700 (PDT)
Message-ID: <20090416.175805.63297521.davem@davemloft.net>
References: <49E72475.5050706@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752238AbZDQA6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 20:58:14 -0400
In-Reply-To: <49E72475.5050706@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Thu, 16 Apr 2009 14:28:37 +0200

> Fix tx ring size reported via ethtool -g.
> 
> Signed-off-by; Brice Goglin <brice@myri.com>
               ^

another semi-colon, you can automate this using git tools
and config settings, or by having a file with your signoff
in it that you copy/paste into outgoing patch emails to prevent
this kind of error

Applied, th anks.

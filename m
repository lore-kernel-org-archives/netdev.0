From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz
 attributes
Date: Fri, 31 Dec 2010 10:42:30 -0800 (PST)
Message-ID: <20101231.104230.226779540.davem@davemloft.net>
References: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753164Ab0LaSmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 13:42:00 -0500
In-Reply-To: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 20 Dec 2010 12:50:13 -0800

> The IEEE8021Qaz is the IEEE standard version of CEE. The
> standard has had enough significant changes from the CEE
> version that many of the CEE attributes have no meaning
> in the new spec or do not easily map to IEEE standards.
> 
> Rather then attempt to create a complicated mapping
> between CEE and IEEE standards this patch adds a nested
> IEEE attribute to the list of DCB attributes. The policy
> is,
 ...
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.

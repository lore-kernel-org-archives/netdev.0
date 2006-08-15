From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] terminology in ip-sysctl.txt
Date: Tue, 15 Aug 2006 01:34:04 -0700 (PDT)
Message-ID: <20060815.013404.14943997.davem@davemloft.net>
References: <20060809072406.GL29602@fi.muni.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33245
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965251AbWHOIeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 04:34:02 -0400
To: kas@fi.muni.cz
In-Reply-To: <20060809072406.GL29602@fi.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kasprzak <kas@fi.muni.cz>
Date: Wed, 9 Aug 2006 09:24:06 +0200

> this minor patch fixes the description of net.ipv4.tcp_mem sysctl
> in ip-sysctl.txt - the headline names the values "min, pressure, max",
> while the description uses the "low, pressure, high" values.
> Both tcp_rmem and tcp_wmem descriptions use the "min, pressure, max"
> values, so I have changed the tcp_mem to match this and not vice versa.
> 
> Signed-Off-By: Jan "Yenya" Kasprzak <kas@fi.muni.cz>

Patch applied, thanks Jan.

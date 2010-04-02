From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] be2net: fix flashing on big endian architectures
Date: Thu, 01 Apr 2010 17:26:20 -0700 (PDT)
Message-ID: <20100401.172620.169243988.davem@davemloft.net>
References: <20100331115709.GA9200@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60826
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756303Ab0DBA0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 20:26:20 -0400
In-Reply-To: <20100331115709.GA9200@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 31 Mar 2010 17:27:10 +0530

> Flashing is broken on big endian architectures like ppc.
> This patch fixes it.
> 
> From: Naresh G <nareshg@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.

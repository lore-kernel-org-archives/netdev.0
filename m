From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/4] be2net: Changes to print fw command
 opcode when command is failed by controller.
Date: Thu, 03 Dec 2009 12:39:50 -0800 (PST)
Message-ID: <20091203.123950.161671837.davem@davemloft.net>
References: <20091203161155.GA1278@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51306
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754744AbZLCUjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:39:44 -0500
In-Reply-To: <20091203161155.GA1278@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 3 Dec 2009 21:42:06 +0530

> When a firmware command fails, only the failure codes are printed.
> It is difficult to co-relate this to the actual command that has failed.
> These changes will now print the command code that has failed.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.

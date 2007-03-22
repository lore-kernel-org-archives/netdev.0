From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] [RESEND] rtnetlink message handler registration
 interface
Date: Thu, 22 Mar 2007 12:06:19 -0700 (PDT)
Message-ID: <20070322.120619.71102556.davem@davemloft.net>
References: <20070322125955.055083236@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965047AbXCVTGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:06:19 -0400
In-Reply-To: <20070322125955.055083236@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 22 Mar 2007 13:59:55 +0100

> The existing function names seem to have sentimental value to some
> people. Same patches but without changes to the functio names.
> 
> Introduces an interface to register rtnetlink message handlers
> and converts all users of rtnl_links[].

All 12 patches applied, thanks Thomas.


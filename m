From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 7/8] qlge: Add support for using alternate MAC
 address.
Date: Wed, 10 Jun 2009 01:05:58 -0700 (PDT)
Message-ID: <20090610.010558.17418233.davem@davemloft.net>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
	<1244561974-25662-7-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756172AbZFJIF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:05:56 -0400
In-Reply-To: <1244561974-25662-7-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue,  9 Jun 2009 08:39:33 -0700

> Extract either manufacturer or Bladecenter Open Fabric
> Manager (BOFM) MAC address.  BOFM may indicate an
> alternate MAC address.  This patch honors that request
> by extracting the MAC address from a different
> flash location if a flag is set.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 2/4] netxen: fix mac list management
Date: Wed, 06 May 2009 15:35:12 -0700 (PDT)
Message-ID: <20090506.153512.122064458.davem@davemloft.net>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
	<1241586309-12112-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758043AbZEFWfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:35:17 -0400
In-Reply-To: <1241586309-12112-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue,  5 May 2009 22:05:07 -0700

> o use standard linked list api for mac addr list management
>   in NX3031.
> o release mac addresses in firmware in dev close().
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.


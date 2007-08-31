From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 00:52:33 -0400
Message-ID: <46D79E91.2040004@psc.edu>
References: <200708310009.RAA04175@tardy.cup.hp.com> <20070830.173912.79067694.davem@davemloft.net> <46D769C1.8090808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:59163 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbXHaEws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 00:52:48 -0400
In-Reply-To: <46D769C1.8090808@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Like I said the consumers of this are a triffle well, 
> "anxious" :)

Just curious, did you or this customer try with F-RTO enabled?  Or is 
this case you're dealing with truly hopeless?

   -John

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/8]qlcnic: inter driver coexistence fixes
Date: Thu, 22 Apr 2010 20:54:48 -0700 (PDT)
Message-ID: <20100422.205448.193698421.davem@davemloft.net>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54549
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755190Ab0DWDyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 23:54:45 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Thu, 22 Apr 2010 05:51:34 -0700

>    Different class of drivers co-exist for CNA device, there is some
>    minimal interaction that will be required amongst the drivers for 
>    performing some device level operations. Operations such as 
>    device initialization, device recovery and device diagnostics test,
>    can potentially affect other function drivers.
>  
>    All these drivers should follow common protocol(IDC) to do such operation.
> 
>    Fixing qlcnic driver according to Inter driver coexistence.
>    
>    Sending series of 8 patches, please apply them in net-next.

All applied, thanks Amit.

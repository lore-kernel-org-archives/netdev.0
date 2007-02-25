From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/7] cxgb3 - FW version update
Date: Sun, 25 Feb 2007 17:39:05 -0500
Message-ID: <45E21009.6040706@garzik.org>
References: <20070225004401.20831.3292.stgit@localhost.localdomain>	 <1172431719.4717.8.camel@stevo-laptop>  <45E1E810.2000706@garzik.org> <1172440758.4717.17.camel@stevo-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35372 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965181AbXBYWjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Feb 2007 17:39:09 -0500
In-Reply-To: <1172440758.4717.17.camel@stevo-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
>> I would rather fix the code to use constants, and thus avoid this 
>> problem ever happening again.
>>
>> 	Jeff
>>
> 
> How's this (not tested)?

seems OK to me



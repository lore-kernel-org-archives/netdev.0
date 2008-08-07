From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] qla3xxx: fix: Remove unused set_multicast function.
Date: Thu, 07 Aug 2008 02:12:06 -0400
Message-ID: <489A9236.5080906@garzik.org>
References: <20080731204514.GA5457@susedev.qlogic.org> <12175371683630-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47929 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832AbYHGGMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:12:09 -0400
In-Reply-To: <12175371683630-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> This device is one side of a two-function adapter (NIC and iSCSI).
> Promiscuous mode setting/clearing is not allowed from the NIC side.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---

applied 1-5



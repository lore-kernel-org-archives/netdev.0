From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Remove fib_local variable
Date: Tue, 09 Aug 2016 14:58:02 -0700 (PDT)
Message-ID: <20160809.145802.1873156215188615511.davem@davemloft.net>
References: <1470750666-28053-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34391 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbcHIV6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:58:05 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so1580791pac.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:58:04 -0700 (PDT)
In-Reply-To: <1470750666-28053-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  9 Aug 2016 06:51:06 -0700

> After commit 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
> fib_local is set but not used. Remove it.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 13/18] natsemi: fix netdev error acounting
Date: Tue, 14 Aug 2007 01:36:46 -0400
Message-ID: <46C13F6E.3060701@garzik.org>
References: <200708102105.l7AL5NBY008983@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, loveminix@yahoo.com.cn, protasnb@gmail.com,
	thockin@hockin.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44523 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941354AbXHNFgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:36:53 -0400
In-Reply-To: <200708102105.l7AL5NBY008983@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> When a detailed netdev error is counted, we also must account for it in the
> aggregated error count.
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=8106
> 
> Cc: Tim Hockin <thockin@hockin.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Chongfeng Hu <loveminix@yahoo.com.cn>
> Cc: Natalie Protasevich <protasnb@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied



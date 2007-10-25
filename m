From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] cpmac: use print_mac() instead of MAC_FMT
Date: Thu, 25 Oct 2007 03:32:09 -0400
Message-ID: <47204679.4010104@pobox.com>
References: <1193193723-12691-1-git-send-email-ejka@imfi.kspu.ru> <1193193723-12691-2-git-send-email-ejka@imfi.kspu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <technoboy85@gmail.com>, netdev@vger.kernel.org
To: Eugene Konev <ejka@imfi.kspu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58970 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761533AbXJYHcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 03:32:22 -0400
In-Reply-To: <1193193723-12691-2-git-send-email-ejka@imfi.kspu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Konev wrote:
> Switch to using DECLARE_MAC_BUF/print_mac() added by commit
> 0795af5729b18218767fab27c44b1384f72dc9ad [NET]: Introduce and use print_mac()
> and DECLARE_MAC_BUF().
> 
> 
> Signed-off-by: Eugene Konev <ejka@imfi.kspu.ru>

applied 1-3



From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 2/5]S2io: Handle and monitor all of the device
 errors and alarms
Date: Fri, 31 Aug 2007 09:02:32 -0400
Message-ID: <46D81168.3040809@garzik.org>
References: <1187223139.23940.333.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53758 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964965AbXHaNCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:02:33 -0400
In-Reply-To: <1187223139.23940.333.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Added support to poll entire set of device errors and alarams.
> - Replaced alarm_intr_handler() with s2io_handle_errors().
> - Added statistic counters to monitor the alarms.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

In general I support as much error handling as is reasonable, but your 
patch description gives us no clue what the benefits of your patch are



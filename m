From: Saikiran Madugula <hummerbliss@gmail.com>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 11:37:37 +0100
Message-ID: <4A3B6A71.9060709@gmail.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Radha Mohan <radhamohan_ch@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:63217 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbZFSKhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 06:37:37 -0400
Received: by ewy6 with SMTP id 6so2407963ewy.37
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 03:37:39 -0700 (PDT)
In-Reply-To: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radha Mohan wrote:
> Hi,
> 
> For an ethernet driver, we need to allocate some pool of SKBs for receiving packets. Is there any way we can reuse the same SKBs without the need to re-allocate in atomic every time one has been used up for netif_rx(). 
> 
> Any pointers will be helpful.
http://kerneltrap.org/mailarchive/linux-netdev/2008/9/28/3433504

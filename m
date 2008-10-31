From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/7] the overdue eepro100 removal
Date: Fri, 31 Oct 2008 00:55:50 -0400
Message-ID: <490A8FD6.5070505@garzik.org>
References: <200810292122.m9TLMF3S020170@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52419 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632AbYJaEzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:55:53 -0400
In-Reply-To: <200810292122.m9TLMF3S020170@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Adrian Bunk <bunk@kernel.org>
> 
> The overdue eepro100 removal.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  Documentation/feature-removal-schedule.txt |    7 
>  MAINTAINERS                                |    5 
>  drivers/net/Kconfig                        |   13 
>  drivers/net/Makefile                       |    1 
>  drivers/net/eepro100.c                     | 2400 -------------------
>  5 files changed, 2426 deletions(-)

applied



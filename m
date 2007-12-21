From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Top 10 kernel oopses/warnings for the week of December 21st
 2007
Date: Fri, 21 Dec 2007 14:09:34 +0000
Message-ID: <20071221140934.5f87bf93@the-village.bc.nu>
References: <476BA8AF.4060201@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	"Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:40208 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751341AbXLUORL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:17:11 -0500
In-Reply-To: <476BA8AF.4060201@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Rank 2: uart_flush_buffer
> 	Warning at drivers/serial/serial_core.c:544 in uart_flush_buffer()
> 	Reported 16 times
> 	No specific version information reported; bug present in 2.6.24-rc5
> 	Caused by a bug in the Bluetooth line discipline/tty code

> Rank 7: uart_write
> 	Warning at drivers/serial/serial_core.c:490 in uart_write()
> 	Reported 2 times

Seems to be more of the Bluetooth stuf


Alan
--
	                "DASD is not really IBM - it has a vowel"
                        -Arjan van de Ven

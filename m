From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: [PATCH net-2.6 V2] tg3: Fix phylib locking strategy
Date: Tue, 06 Oct 2009 07:45:42 +0200
Message-ID: <4ACAD986.6060205@embedded-sol.com>
References: <1254801692.18507@xw6200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	andy@greyhouse.net
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:58156 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284AbZJFFqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 01:46:20 -0400
In-Reply-To: <1254801692.18507@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Matt

Matt Carlson wrote:
> O.K.  Here is the latest version.  Felix, can you verify your problem
> is solved with this patch?
>
>   
Thanks for the patch. I don't have the board with Broadcom NIC at the 
moment.
Hopefully I'll get it back in a couple of days and will test your patch.

Felix.

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] Blackfin EMAC Driver: code cleanup
Date: Tue, 29 Apr 2008 01:59:28 -0400
Message-ID: <4816B940.1080203@garzik.org>
References: <1209095591-20920-1-git-send-email-cooloney@kernel.org> <1209095591-20920-2-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53385 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbYD2F7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:59:30 -0400
In-Reply-To: <1209095591-20920-2-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
>  - replace specific "bf537" function or data structure name to "bfin_mac"
>  - cleanup bfin_mac_probe with error checking
>  - punt set_pin_mux function, call peripheral request/free list functions directly
> 
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

applied 1-2



From: jamal <hadi@cyberus.ca>
Subject: Re: Oops in IFB
Date: Thu, 20 Jul 2006 09:40:00 -0400
Message-ID: <1153402801.5098.66.camel@jzny2>
References: <44BF8628.9080204@6wind.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:13496 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1030304AbWGTNkI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 09:40:08 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G3Yl7-0005wR-Ch
	for netdev@vger.kernel.org; Thu, 20 Jul 2006 09:40:09 -0400
To: nicolas.dichtel@6wind.com
In-Reply-To: <44BF8628.9080204@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-20-07 at 15:33 +0200, Nicolas DICHTEL wrote:


> [IFB] After ifb_init_one() failed, i is increased. Decrease
> it before entering in the loop for freeing the other ifb devices.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks Nicolas.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal


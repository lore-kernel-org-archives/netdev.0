From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Wed, 18 May 2011 08:59:32 +0200
Message-ID: <4DD36E54.9040706@neli.hopto.org>
References: <1305696161-18277-1-git-send-email-micha@neli.hopto.org>	<20110518.020716.447947355233874982.davem@davemloft.net>	<4DD36803.1020001@neli.hopto.org> <20110518.023725.441358922110721042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.172]:52459 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab1ERG7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 02:59:33 -0400
In-Reply-To: <20110518.023725.441358922110721042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Op 2011-05-18 8:37, David Miller schreef:
> From: Micha Nelissen<micha@neli.hopto.org>
> Date: Wed, 18 May 2011 08:32:35 +0200
>
>> I'm confused. Against which tree/commit do you want it then?
>
> Linus's current tree would be fine as would:
>
> 	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

Ok I see, thanks. The patch should apply just fine to your tree, there 
is only a spelling change since 2.6.38 which does not conflict.

Micha

From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-softmac: Init, shutdown and restart fixes
Date: Mon, 11 Sep 2006 14:35:01 -0500
Message-ID: <4505BA65.9050201@lwfinger.net>
References: <44E9C6A0.3090107@lwfinger.net> <200608211653.01997.mb@bu3sch.de> <20060911182857.GA19326@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:34951 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964999AbWIKTfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 15:35:16 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060911182857.GA19326@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
>> Either move bcm43xx_periodic_tasks_setup after rng_init, or
>> delete the periodic work again, if rng_init fails.
> 
> Larry, will you be posting another patch to account for these comments?

Yes - coming right after this message.

Larry

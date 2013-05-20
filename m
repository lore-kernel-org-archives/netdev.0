From: Sylwester Nawrocki <sylvester.nawrocki@gmail.com>
Subject: Re: [PATCH v3] net: dm9000: Allow instantiation using device tree
Date: Mon, 20 May 2013 22:11:04 +0200
Message-ID: <519A8358.9040607@gmail.com>
References: <1369077418-5966-1-git-send-email-tomasz.figa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Grant Likely <grant.likely@linaro.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Tomasz Figa <tomasz.figa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:57819 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756421Ab3ETULJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:11:09 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm19so3795074bkc.30
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 13:11:08 -0700 (PDT)
In-Reply-To: <1369077418-5966-1-git-send-email-tomasz.figa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2013 09:16 PM, Tomasz Figa wrote:
> This patch adds Device Tree support to dm9000 driver.
>
> Signed-off-by: Tomasz Figa<tomasz.figa@gmail.com>

Looks good. I'm going to test also this version at the end of this
week on Mini2440.

Reviewed-by: Sylwester Nawrocki <sylvester.nawrocki@gmail.com>

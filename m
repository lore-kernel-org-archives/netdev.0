From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 0/2] STMMAC: MDIO settings
Date: Thu, 17 Mar 2016 14:10:17 +0100
Message-ID: <56EAACB9.40803@st.com>
References: <1458121942-5537-1-git-send-email-peppe.cavallaro@st.com> <20160316.180905.1210684680763742658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <gabriel.fernandez@linaro.org>,
	<afaerber@suse.de>, <fschaefer.oss@googlemail.com>,
	<dinh.linux@gmail.com>, <preid@electromag.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:57099 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966826AbcCQNKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 09:10:41 -0400
In-Reply-To: <20160316.180905.1210684680763742658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/2016 11:09 PM, David Miller wrote:
>
> Don't _ever_ send the same two sets of patches targetting net and
> net-next at the same time.

cover-letter reports the difference between the two patches for
net and next.

> Especially right now, as 'net' is basically frozen, and 'net-next' is
> closed for new features and is only for last minute bug fixes before I
> send a merge window pull request to Linus.

I do think that:

     [PATCH (net-next.git) 0/2] STMMAC: MDIO settings
     [PATCH (net-next.git)] stmmac: fix TX normal DESC

are last minute bug fixes for net-next.

Peppe

>
> I'm tossing both of these series, figure it how to do this properly.

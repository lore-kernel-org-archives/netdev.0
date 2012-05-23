From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/4] stmmac: modify and improve the bus_setup platform
 callback
Date: Wed, 23 May 2012 08:19:02 +0200
Message-ID: <4FBC8156.6010101@st.com>
References: <1337751619-21941-1-git-send-email-peppe.cavallaro@st.com> <20120523.014359.1912436981409831773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:54127 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932910Ab2EWGTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:19:10 -0400
In-Reply-To: <20120523.014359.1912436981409831773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David

On 5/23/2012 7:43 AM, David Miller wrote:
> 
> As I stated the other day, the net-next tree is closed, therefore only
> bug fixes are appropriate at this time.

Ok, so only these patches shouldbe considered:

  stmmac: update driver's doc
  stmmac: remove two useless initialisation
  stmmac: remove two useless initialisation

and

  stmmac: fix driver Kconfig when built as module
     This is attached to another thread and under review.


> If there are bug fixes you want integrated in this series, you need
> to seperate them out and submit them only at this time.

Thanks, I'm resending them again for net.git.

> When net-next opens back up you can submit the rest.

I'll only resend the following patch (that should be stay in next repo)
later:
     stmmac: modify and improve the bus_setup platform callback

Regards
Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

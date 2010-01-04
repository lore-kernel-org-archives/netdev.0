From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [RESEND PATCH 2/4] stmmac: add the new Header file for stmmac
 platform data
Date: Mon, 04 Jan 2010 08:22:19 +0100
Message-ID: <4B41972B.4080002@st.com>
References: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>	<1260948405-28511-2-git-send-email-peppe.cavallaro@st.com> <20091225.182501.39194553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:59534 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752096Ab0ADHWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 02:22:24 -0500
In-Reply-To: <20091225.182501.39194553.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Wed, 16 Dec 2009 08:26:43 +0100
> 
>> +#define __STMMAC_PLATFORM_DATA __FILE__
> 
> Why is this defining this to __FILE__?  An empty
> definition is colloquial and sufficient.

OK, I'll fix it as well.
I'll send the new patch as soon as possible.
Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktBlysACgkQ2Xo3j31MSSKUlgCffZ47WRpimHoj+8EY5UbJRmme
AzUAoKZ7mV9rMbzSl74wySM14D4oQWdR
=JTn0
-----END PGP SIGNATURE-----

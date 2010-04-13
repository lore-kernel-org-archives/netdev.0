From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] (net-2.6) stmmac update - Apr 2010
Date: Tue, 13 Apr 2010 12:00:09 +0200
Message-ID: <4BC440A9.5000008@st.com>
References: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com> <20100413.015352.223941252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:38977 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752170Ab0DMKAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:00:30 -0400
In-Reply-To: <20100413.015352.223941252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

On 04/13/2010 10:53 AM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Fri,  9 Apr 2010 12:24:15 +0200
> 
>> Hello,
>> this is another subset of patches to make the driver more generic.
>>
>> This patches splits the dma and core code for the mac 10/100 device
>> (as already done for the gmac) and reorganizes the descriptor
>> structures.
>> In the first version of the driver, the mac10/100 could only use
>> normal descriptors and the gmac could only use the enhanced ones.
>> This limit has been removed and this kind of information comes
>> from the platform.
> 
> Please:
> 
> 1) respin your patches against net-next-2.6

I'll do this soon.

> 2) Add numbers to your patch posting subject lines so there
>    is no confusion about what order your patches should be
>    applied.

Oops! you are right. Thanks!

> 
> 3) Make sure the driver compiles successfully at each step
>    of applying your patches, not just after all the changes
>    are applied.

Sure! I test this always.

Many thanks.

Best Regards
Giuseppe

> Thanks.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBAgAGBQJLxECpAAoJEAm9vY9TshdvuH8H/RbUTVa+o7qJjRyXgb34h5t4
KSwdcnWwY90d2i/3zLvWlwaSn4J5zrSWc6EdXRpU/1zBI+xcQ0wAFieqF8R0QOoE
qIKliOPCJ7NrsV30J4xhe2R0q7e423vmTdUfcNB1VXqBaZOQOPZmKjApRT240c6E
CwLfTANwAQ6t8pl6rlyww/nTEPuOVx0ETvAGEfHloWa3Sr5TvgXndfD2dnDU9cs1
wgg/6YzehTRioMM3Rf7KySuVMcENbCkyy3R4zSNvwJONZqVqMkTWDZ1XIpq3BvpV
r2AAjXdXtVB2Z6lroP2UVCrYLcm3LB0WUdzTqrj0zpzW9cm1DEOb2nhjcWVLNHY=
=h25h
-----END PGP SIGNATURE-----

From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 00/14] Add common OF device tree support for MDIO busses
Date: Tue, 31 Mar 2009 22:56:38 -0600
Message-ID: <fa686aa40903312156m2aad029i7dc27700bc9418fb@mail.gmail.com>
References: <fa686aa40903311519m3108c697v52180d192975a3b1@mail.gmail.com>
	 <20090331.152237.210090951.davem@davemloft.net>
	 <fa686aa40903311845v54ddfb91u56dd11eff64140d4@mail.gmail.com>
	 <20090331.203855.96368726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, olof@lixom.net,
	afleming@freescale.com, galak@kernel.crashing.org,
	avorontsov@ru.mvista.com, Joakim.Tjernlund@transmode.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:15239 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbZDAE4l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 00:56:41 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2789024yxl.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 21:56:39 -0700 (PDT)
In-Reply-To: <20090331.203855.96368726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 9:38 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Tue, 31 Mar 2009 19:45:02 -0600
>
>> Dammit. =A0Why did you have to go and sound so reasonable when I was=
 all
>> geared up for a pointless flame war.
>>
>> well... alright... but I reserve the right to be grumpy and surly fo=
r
>> a few days.
>
> :-)
>
> Just in case you decided to continue, I did cover my ass by
> making an explicit posting explaining the policy and the
> intent on netdev last week:
>
> http://marc.info/?l=3Dlinux-netdev&m=3D123814105015481&w=3D2

At the very least, please consider picking up patches 2 & 3.  They
address a real bug (unrelated to the MDIO rework), and only touch the
MPC5200 FEC driver.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.

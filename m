From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Question on multicast.
Date: Wed, 12 Mar 2014 14:06:00 +0100
Message-ID: <53205BB8.6020406@6wind.com>
References: <531F85BF.10504@candelatech.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:61500 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbaCLNGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 09:06:03 -0400
Received: by mail-we0-f177.google.com with SMTP id u57so10962625wes.8
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 06:06:02 -0700 (PDT)
In-Reply-To: <531F85BF.10504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/03/2014 22:53, Ben Greear a =E9crit :
> Is it sane to have multiple multicast transmitters using same IGMP gr=
oup
> and destination port in the same routed network?
I think there is no fundamental problem. It depends on what you want to=
 do ;-)
Listeners can filter by source address if they need.


Regards,
Nicolas

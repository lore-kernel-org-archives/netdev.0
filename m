From: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: [PATCH v2 net-next 1/2] be2net: Modify GPL Marking in all
 source files.
Date: Wed, 23 Jan 2013 07:28:17 +0000
Message-ID: <32aacb12-c1af-4cff-becb-eb046eef0d6e@CMEXHTCAS2.ad.emulex.com>
References: <c09a42d1-150f-4d78-b2c4-2bedec3bd577@CMEXHTCAS2.ad.emulex.com>
 <20130123.020618.638425092581514860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vasundhara, Volam" <Vasundhara.Volam@Emulex.Com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:2209 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab3AWH2S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 02:28:18 -0500
In-Reply-To: <20130123.020618.638425092581514860.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
Can I assume that the first 3 points are acceptable (copyright being extended, adding EMULEX/SLI as trademarks, and adding website information)?

As for the last one about disclaimer, most driver had it all the time and benet did not. It  mentions section 15 "Disclaimer of Warranty" of gpl license explicitly 
(http://www.gnu.org/licenses/gpl.html). 

Is there an issue with this?

Thanks,
Sarvesh

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, January 23, 2013 12:36 PM
To: Bandi,Sarveshwar
Cc: netdev@vger.kernel.org; Vasundhara, Volam
Subject: Re: [PATCH v2 net-next 1/2] be2net: Modify GPL Marking in all source files.

From: <sarveshwar.bandi@emulex.com>
Date: Wed, 23 Jan 2013 12:22:03 +0530

> From: Vasundhara Volam <vasundhara.volam@emulex.com>
> 
> The following modifications have been made to copyright:
> - years of copyright extended to include 2013
> - specify EMULEX and SLI as trademarks of Emulex corporation
> - specify emulex website
> - Added a more detailed disclaimer " ALL EXPRESS OR IMPLIED 
> CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED 
> WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR 
> NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT THAT SUCH 
> DISCLAIMERS ARE HELD TO BE LEGALLY INVALID."
> 
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

You're just essentially reading the contents of the patch, that's not satisfactory.

In particular, the problem is that you aren't explaining why you're making all of these changes.

There needs to be justification for copyright changes like this, you are not providing them.

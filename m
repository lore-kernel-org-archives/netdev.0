From: "Bandi, Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: [PATCH net] be2net: Fix to avoid hardware workaround when not
 needed
Date: Wed, 17 Jul 2013 03:03:52 +0000
Message-ID: <9D1F9FE58F08ED47AA451ABB038550E936D5179F@CMEXMB1.ad.emulex.com>
References: <458bdd84-53ce-489e-b134-f435c5fd6a50@CMEXHTCAS2.ad.emulex.com>
 <20130716.130358.711125572475101678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52662 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3GQDDx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 23:03:53 -0400
In-Reply-To: <20130716.130358.711125572475101678.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
  Please queue up this patch for 3.10 stable.

Thanks,
Sarvesh
  

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, July 17, 2013 1:34 AM
To: Bandi, Sarveshwar
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH net] be2net: Fix to avoid hardware workaround when not needed

From: <sarveshwar.bandi@emulex.com>
Date: Tue, 16 Jul 2013 12:44:02 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Hardware workaround requesting hardware to skip vlan insertion is 
> necessary only when umc or qnq is enabled. Enabling this workaround in 
> other scenarios could cause controller to stall.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied.

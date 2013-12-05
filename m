From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net 0/3] be2net fixes
Date: Thu, 5 Dec 2013 05:38:21 +0000
Message-ID: <7F44EA5110810A40B7DAFB605C41975D2C96274B@CMEXMB1.ad.emulex.com>
References: <72e434bb-7c52-4dbe-a406-c6e0ad49e909@CMEXHTCAS2.ad.emulex.com>
 <20131205.001111.273727362951023546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:24365 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab3LEFiX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:38:23 -0500
In-Reply-To: <20131205.001111.273727362951023546.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> From: Somnath Kotur <somnath.kotur@emulex.com>
> Date: Thu, 5 Dec 2013 10:34:00 +0530
> 
> >   be2net: Log a kernel message when the user tries to configure more
> >     Multicast addresses than supported
> 
> This is absolutely not appropriate.
Hi Dave,
         	Sorry, but i'm not sure sure I understand what is the inappropriate part here ?
 Is it the fact that we chose to log a kernel message when the user tries to configure more MC addresses ? 

Thanks
Som

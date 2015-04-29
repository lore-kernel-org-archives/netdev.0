From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v3] be2net: log link status
Date: Wed, 29 Apr 2015 09:17:50 +0000
Message-ID: <afae13d0-679e-4eb0-a044-425e81d0cf71@CMEXHTCAS2.ad.emulex.com>
References: <553FE1F4.60402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	"Ajit Kumar Khaparde" <Ajit.Khaparde@Emulex.Com>,
	David Miller <davem@davemloft.net>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:2076 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422805AbbD2JSW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 05:18:22 -0400
In-Reply-To: <553FE1F4.60402@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> 
> The driver unlike other drivers does not log link state changes. It's
> better for an user when asynchronous link states are logged in the
> system log.
> 
> v3: Changes from v2 discarded as "not necessary"
> 
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Sathya Perla <sathya.perla@emulex.com>

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 6 Sep 2007 08:11:28 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABA42@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070906134508.GA10317@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: "Andy Gospodarek" <andy@greyhouse.net>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4731 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758264AbXIFPLn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 11:11:43 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070906134508.GA10317@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:

> This patch was designed to address tg3 and bnx2 messages printed on
> systems with HT1000 chips IIRC.  Are we going back to those 
> messages on
> bnx2 or is there a workaround in that driver needed too?
> 

Andy, I've checked all the Broadcom chips including bnx2 chips, only
the 5714 and 5780 have this problem.


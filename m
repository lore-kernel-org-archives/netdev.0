From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Mon, 01 May 2006 14:32:46 -0700 (PDT)
Message-ID: <20060501.143246.112559350.davem@davemloft.net>
References: <20060428195930.GB21294@2ka.mipt.ru>
	<20060428.150056.18940876.davem@davemloft.net>
	<20060429124451.GA19810@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37611
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932242AbWEAVeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 17:34:00 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060429124451.GA19810@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 29 Apr 2006 16:44:51 +0400

> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

I understand how in some ways this is work in progress,
but direct calls into ext3 from the kevent code?  I'd
like stuff like that cleaned up before reviewing :-)

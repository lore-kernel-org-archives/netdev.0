From: Jeff Garzik <jeff@garzik.org>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Thu, 22 Jun 2006 21:20:20 -0400
Message-ID: <449B41D4.7000802@garzik.org>
References: <0BB3E5E7462EEA4295BC02D49691DC0717688F@AVEXCH1.qlogic.org>	<449B2621.7080607@garzik.org> <adapsh0losd.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ron Mercer <ron.mercer@qlogic.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-driver@qlogic.com,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56194 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932747AbWFWBU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 21:20:27 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adapsh0losd.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > 15) I wonder if SA_SHIRQ needs to be set, for MSI?
> 
> Why would it?  MSI vectors are always unique, aren't they?

Precisely what my question implies...

	Jeff




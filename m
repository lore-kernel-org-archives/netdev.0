From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 0/2] QE clock source improvements
Date: Wed, 10 Oct 2007 17:31:47 -0500
Message-ID: <470D52D3.30104@freescale.com>
References: <1192054708946-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:42649 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbXJJWcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:32:04 -0400
In-Reply-To: <1192054708946-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, please ignore this set.  Something got screwed up with the patches. 
I'm going to resend.

Timur Tabi wrote:
> This patch set adds a new property to make specifying QE clock sources
> easier, adds a function to help parse the property, updates some other
> functions to use an enum instead of an integer, and updates the ucc_geth
> driver to take advantage of all this.
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
> 


-- 
Timur Tabi
Linux Kernel Developer @ Freescale

From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: patch usb-option.c-remove-duplicate-device-ids-now-supported-in-hso.c.patch
 added to gregkh-2.6 tree
Date: Thu, 02 Oct 2008 14:02:30 +0200
Message-ID: <48E4B856.4030104@option.com>
References: <12228964171165@kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:45845 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbYJBMCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 08:02:44 -0400
In-Reply-To: <12228964171165@kroah.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gregkh@suse.de wrote:
> This is a note to let you know that I've just added the patch titled
> 
>     Subject: USB: option.c remove duplicate device ids now supported in hso.c
> 
> to my gregkh-2.6 tree.  Its filename is
> 
>     usb-option.c-remove-duplicate-device-ids-now-supported-in-hso.c.patch
> 
> This tree can be found at 
>     http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/
Hi Greg,
I confirmed that hso.c works as a normal modem driver with wvdial so this patch
should not have adverse effects on the usability of these devices.

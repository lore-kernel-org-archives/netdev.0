From: Stefan Metzmacher <metze@samba.org>
Subject: RE: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Wed,  1 Jun 2011 14:01:40 +0200
Message-ID: <1306929701-22861-1-git-send-email-metze@samba.org>
References: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E568@EXDCVYMBSTM006.EQ1STM.local>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.182]:56981 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758768Ab1FAMB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 08:01:58 -0400
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E568@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here comes the patch with the DRIVER_VERSION change.

Are there chances to get this also backported in stable kernel.
I need it for 2.6.38.x (ubuntu 11.04).

metze


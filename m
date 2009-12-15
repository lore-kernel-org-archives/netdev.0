From: stefano babic <stefano.babic@babic.homelinux.org>
Subject: Re: [RFC PATCH v3  7/8] CAIF Protocol Stack
Date: Tue, 15 Dec 2009 18:12:12 +0100
Message-ID: <4B27C36C.6060204@babic.homelinux.org>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-7-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-8-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout23.attiva.biz ([85.37.16.24]:30124 "EHLO
	smtpout23.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbZLORM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 12:12:28 -0500
In-Reply-To: <1259593252-2493-8-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:

> +Linux GPRS Net Device and Character Devices

We have now only net devices

> +Configuration of Drivers
> +------------------------
> +
> +Configuration is the most complex part of the CAIF protocol.
> +Configuration is controlled by the Misc device 'caifconfig'
> +implemented in caif_chr.

This documentation was not updated, you get rid of 'caifconfig'

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

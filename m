From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [6/8,RFC] CAIF Protocol Stack
Date: Mon, 05 Oct 2009 17:17:57 +0200
Message-ID: <4ACA0E25.5010207@babic.homelinux.org>
References: <1253727091-10383-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kim.xx.Lilliestierna@ericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout09.attiva.biz ([85.37.16.7]:11102 "EHLO
	smtpout09.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbZJEPSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 11:18:36 -0400
In-Reply-To: <1253727091-10383-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>
> 
> Signed-off-by: sjur.brandeland@stericsson.com

Hi Sjur,

>  drivers/net/caif/chnl_tty.c   |  220 +++++++++++

There is no rule in drivers/net/caif/Makefile regarding this file and it
is not mentioned in the documentation. Is there anything missing ? I
supposed the serial physical layer is implemented in phyif_ser.c.

Regards,
Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

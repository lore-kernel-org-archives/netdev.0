From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net 1/1] 8139cp: revert "set ring address before enabling
 receiver"
Date: Wed, 21 Nov 2012 22:44:02 -0500
Message-ID: <50AD9F82.6030609@pobox.com>
References: <20121121200729.GA17603@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>,
	Jason Wang <jasowang@redhat.com>, gilboad@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:54140 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294Ab2KVUJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 15:09:24 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so5008983vcm.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 12:09:24 -0800 (PST)
In-Reply-To: <20121121200729.GA17603@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2012 03:07 PM, Francois Romieu wrote:
> This patch reverts b01af4579ec41f48e9b9c774e70bd6474ad210db.
>
> The original patch was tested with emulated hardware. Real
> hardware chokes.
>
> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=47041
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Acked-by: Jeff Garzik <jgarzik@redhat.com>

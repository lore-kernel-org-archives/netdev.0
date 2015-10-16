From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] ip monitor neigh: Change 'delete' to 'Deleted'
 to be consistent with ip route
Date: Fri, 16 Oct 2015 09:18:59 +0200
Message-ID: <5620A4E3.1000202@6wind.com>
References: <1444934863-12704-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:34266 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbbJPHTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:19:03 -0400
Received: by lfaz124 with SMTP id z124so72247259lfa.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 00:19:01 -0700 (PDT)
In-Reply-To: <1444934863-12704-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/10/2015 20:47, Roopa Prabhu a =C3=A9crit :
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> It helps to grep for one string "Deleted" when monitoring all events.
>
> Fixes: 6ea3ebafe077 ("iproute2: inform user when a neighbor is remove=
d")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
> I am not sure if it is too late for this change. But, sending this pa=
tch
> out because it only affects ip monitor output
Seems reasonable to me, but I let Stephen speaking at this.

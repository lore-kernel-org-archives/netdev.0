From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] ipv6: include NLM_F_REPLACE in route replace
 notifications
Date: Mon, 14 Sep 2015 09:52:09 +0200
Message-ID: <55F67CA9.3090908@6wind.com>
References: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mkubecek@suse.cz, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37116 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbINHwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 03:52:12 -0400
Received: by wicfx3 with SMTP id fx3so120981476wic.0
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 00:52:11 -0700 (PDT)
In-Reply-To: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/09/2015 19:18, Roopa Prabhu a =C3=A9crit :
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds NLM_F_REPLACE flag to ipv6 route replace notification=
s.
> This makes nlm_flags in ipv6 replace notifications consistent
> with ipv4.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] lwt: Add support to redirect dst.input
Date: Fri, 14 Aug 2015 00:07:13 -0700
Message-ID: <55CD93A1.9010606@cumulusnetworks.com>
References: <1439484843-3848061-1-git-send-email-tom@herbertland.com> <1439484843-3848061-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36045 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbbHNHHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 03:07:15 -0400
Received: by pacrr5 with SMTP id rr5so54536765pac.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 00:07:14 -0700 (PDT)
In-Reply-To: <1439484843-3848061-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/13/15, 9:54 AM, Tom Herbert wrote:
> This patch adds the capability to redirect dst input in the same way
> that dst output is redirected by LWT.
>
> Also, save the original dst.input and and dst.out when setting up
> lwtunnel redirection. These can be called by the client as a pass-
> through.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> -
LGTM. Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks,
Roopa

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: davinci_emac: Remove unwanted debug/error message
Date: Tue, 03 Jun 2014 20:29:40 +0400
Message-ID: <538DF7F4.2080806@cogentembedded.com>
References: <1401768978-22284-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:35545 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932469AbaFCQ3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 12:29:37 -0400
Received: by mail-la0-f49.google.com with SMTP id pv20so3621642lab.36
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 09:29:35 -0700 (PDT)
In-Reply-To: <1401768978-22284-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/03/2014 08:16 AM, Christian Riesch wrote:

> In commit cd11cf505318ff24e42f35145f9cdf8596fa1958 I accidentally

    Please also specify that commit's summary line in parens.

> added an error message. I used it for debugging and forgot to remove
> it before submitting the patch.

> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

WBR, Sergei

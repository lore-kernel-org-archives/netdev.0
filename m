From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] tg3: fix to append hardware time stamping flags
Date: Tue, 30 Apr 2013 20:58:51 +0400
Message-ID: <517FF84B.4090008@cogentembedded.com>
References: <1367330977-6470-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:32790 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761335Ab3D3Q70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 12:59:26 -0400
Received: by mail-la0-f47.google.com with SMTP id em20so628251lab.6
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 09:59:24 -0700 (PDT)
In-Reply-To: <1367330977-6470-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/30/2013 06:09 PM, Flavio Leitner wrote:

> The commit f233a976ad15c3b8c54c0157f3c41d23f7514279 fixing the

    Please also specify that commit's summary in parens.

> hardware time stamping support didn't append hardware flags.
> This patch fixes it.
>
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

WBR, Sergei

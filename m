From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: phy.c: Cleaning up
 uninitialized variables
Date: Sun, 01 Jun 2014 23:32:27 +0400
Message-ID: <538B7FCB.5090106@cogentembedded.com>
References: <1401626948-16183-1-git-send-email-rickard_strandqvist@spectrumdigital.se>	<538B5714.6060107@cogentembedded.com> <CAFo99gYJ_K9qEaHihtvaFT4Wv3ApUZMJmTK=nuqK+=sA2NaYsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:63369 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbaFATc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 15:32:29 -0400
Received: by mail-lb0-f181.google.com with SMTP id q8so2022198lbi.40
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 12:32:27 -0700 (PDT)
In-Reply-To: <CAFo99gYJ_K9qEaHihtvaFT4Wv3ApUZMJmTK=nuqK+=sA2NaYsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/01/2014 08:44 PM, Rickard Strandqvist wrote:

> Okay, sorry. But you agree with what it is doing in general then?

    Now that you asked, I do agree. But generally my reply doesn't mean that I 
went and studied the patch context and verified that the patch is indeed correct.

> In this case, I am sending a new patch...

    BTW, it's worth mentioning in the change log that you're moving the 
variable in question into the block.

> Best regards
> Rickard Strandqvist

WBR, Sergei

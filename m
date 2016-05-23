From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH 1/1] tc fix ife late binding
Date: Mon, 23 May 2016 16:16:06 -0700
Message-ID: <20160523161606.71cd3c6c@xeon-e3>
References: <1463937076-31395-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35782 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbcEWXPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 19:15:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id g64so70100pfb.2
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 16:15:53 -0700 (PDT)
In-Reply-To: <1463937076-31395-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 May 2016 13:11:16 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> following late binding didn't work
> 
> sudo tc actions add action ife encode \
> type 0xDEAD allow mark dst 02:15:15:15:15:15 index 1
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied

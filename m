From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] lib utils: Use helpers to get AF bit/byte len
Date: Sun, 15 Mar 2015 12:16:48 -0700
Message-ID: <20150315121648.7a7afc51@urahara>
References: <1425084624-20025-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34650 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbbCOTQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:16:47 -0400
Received: by pacwe9 with SMTP id we9so42374344pac.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:16:47 -0700 (PDT)
In-Reply-To: <1425084624-20025-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Feb 2015 02:50:24 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added funcs to get AF_XXX len in bit/bytes and replace
> places where switch(AF_XXX) is used for this.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied, thanks

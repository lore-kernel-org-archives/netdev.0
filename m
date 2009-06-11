From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH] netdev: dm9000: require compat net dev ops
Date: Thu, 11 Jun 2009 19:51:04 -0400
Message-ID: <8bd0f97a0906111651r30310598la58774d8ee0bf3ad@mail.gmail.com>
References: <1244761350-2823-1-git-send-email-vapier@gentoo.org>
	<20090611.164908.11590745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:57462 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981AbZFKX5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:57:45 -0400
Received: by gxk10 with SMTP id 10so2923387gxk.13
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 16:57:47 -0700 (PDT)
In-Reply-To: <20090611.164908.11590745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 19:49, David Miller wrote:
> From: Mike Frysinger Thu, 11 Jun 2009 19:02:30 -0400
>> The dm9000 driver hasn't been upgraded yet, so select the compat net dev
>> ops option for now.
>
> This config option no longer exists in the networking tree.

so compat support no longer exists, or dm9000 has been fixed, or
dm9000 is broken, or dm9000 is dropped, or ...... ?
-mike

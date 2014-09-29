From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip link: Shortify printing the usage of link
 type
Date: Mon, 29 Sep 2014 08:50:38 -0700
Message-ID: <20140929085038.7d2b5de3@urahara>
References: <1411166627-23848-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36883 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbaI2Puv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 11:50:51 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so4753180pad.30
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 08:50:51 -0700 (PDT)
In-Reply-To: <1411166627-23848-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2014 01:43:47 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> Allow to print particular link type usage by:
> 
>     ip link help [TYPE]
> 
> Currently to print usage for some link type it is needed
> to use the following way:
> 
>     ip link { add | del | set } type TYPE help
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

I like this, but does not apply to current iproute2 tree.
Probably because I took in some other patches.

From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] tc: add support for Flower classifier
Date: Thu, 21 May 2015 15:23:38 -0700
Message-ID: <20150521152338.69922d6f@urahara>
References: <1431689644-7321-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34312 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbbEUWXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:23:35 -0400
Received: by pabru16 with SMTP id ru16so1595860pab.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 15:23:34 -0700 (PDT)
In-Reply-To: <1431689644-7321-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 May 2015 13:34:04 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/pkt_cls.h |  30 +++
>  tc/Makefile             |   1 +
>  tc/f_flower.c           | 540 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 571 insertions(+)
>  create mode 100644 tc/f_flower.c
> 

Applied to net-next
Headers done separately already.

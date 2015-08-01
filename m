From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: Preserve original portocol family in batch mode
Date: Fri, 31 Jul 2015 18:11:26 -0700
Message-ID: <20150731181126.3eaa3700@urahara>
References: <1438340131-13882-1-git-send-email-antti.paila@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Antti Paila <antti.paila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36697 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbHABLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 21:11:18 -0400
Received: by pachj5 with SMTP id hj5so48757677pac.3
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 18:11:17 -0700 (PDT)
In-Reply-To: <1438340131-13882-1-git-send-email-antti.paila@stonesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Jul 2015 13:55:31 +0300
Antti Paila <antti.paila@gmail.com> wrote:

> From: Antti Paila <antti.paila@gmail.com>
> 
> Reset the 'preferred_family' global variable
> to its initially set value before each batch
> file command is processed.
> 
> Signed-off-by: Antti Paila <antti.paila@gmail.com>

Applied for 4.2 release.

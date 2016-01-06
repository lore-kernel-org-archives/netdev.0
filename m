From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] tipc: add peer remove functionality
Date: Wed, 6 Jan 2016 09:27:58 -0800
Message-ID: <20160106092758.31283f25@xeon-e3>
References: <1451987860-17696-1-git-send-email-richard.alpe@ericsson.com>
	<1451987860-17696-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33258 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAFR1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 12:27:50 -0500
Received: by mail-pa0-f48.google.com with SMTP id cy9so236819604pac.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 09:27:50 -0800 (PST)
In-Reply-To: <1451987860-17696-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Jan 2016 10:57:40 +0100
Richard Alpe <richard.alpe@ericsson.com> wrote:

> This enables a user to remove an offline peer from the kernel data
> structures. This could for example be useful when deliberately scaling
> in peer nodes in a cloud environment.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Both applied thanks.

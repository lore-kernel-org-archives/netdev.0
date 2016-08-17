From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 2/2] tipc: refactor bearer identification
Date: Wed, 17 Aug 2016 13:53:30 -0700
Message-ID: <20160817135330.54db24b5@xeon-e3>
References: <1471249472-2554-1-git-send-email-richard.alpe@ericsson.com>
	<1471249472-2554-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33313 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbcHQUxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 16:53:25 -0400
Received: by mail-pa0-f41.google.com with SMTP id ti13so39344314pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 13:53:19 -0700 (PDT)
In-Reply-To: <1471249472-2554-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2016 10:24:32 +0200
Richard Alpe <richard.alpe@ericsson.com> wrote:

> Introduce a generic function (nl_add_bearer_name()) that identifies a
> bearer and adds it to an existing netlink message. This reduces code
> complexity and makes the code a little bit easier to maintain.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

Thanks for keeping TIPC support up to date.
Applied.

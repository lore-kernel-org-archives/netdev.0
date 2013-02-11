From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next] bridge: use dev->addr_assign_type to see if
 user change mac
Date: Mon, 11 Feb 2013 10:54:08 -0800
Message-ID: <20130211105408.5e79f5bc@nehalam.linuxnetplumber.net>
References: <1360532461-21003-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:64741 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab3BKSyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 13:54:23 -0500
Received: by mail-da0-f47.google.com with SMTP id s35so2870202dak.34
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 10:54:22 -0800 (PST)
In-Reply-To: <1360532461-21003-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Feb 2013 22:41:01 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> And remove no longer used br->flags.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ipaddress: needs to include <sys/param.h>
Date: Mon, 23 May 2016 16:13:50 -0700
Message-ID: <20160523161350.49c952d7@xeon-e3>
References: <1463678986-3732-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gustavo Zacarias <gustavo@zacarias.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36695 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbcEWXNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 19:13:37 -0400
Received: by mail-pf0-f169.google.com with SMTP id c189so40999pfb.3
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 16:13:37 -0700 (PDT)
In-Reply-To: <1463678986-3732-1-git-send-email-gustavo@zacarias.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 May 2016 14:29:46 -0300
Gustavo Zacarias <gustavo@zacarias.com.ar> wrote:

> It's using MIN() now, otherwise it breaks for musl libc.
> 
> Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>

Makes sense. Applied

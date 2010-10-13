From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Wed, 13 Oct 2010 07:18:32 -0400
Message-ID: <4CB59588.1010807@cox.net>
References: <loom.20101012T185411-307@post.gmane.org> <1286905245.2703.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtai102.cox.net ([68.230.240.21]:38009 "EHLO
	eastrmmtai102.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826Ab0JMLYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 07:24:09 -0400
In-Reply-To: <1286905245.2703.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> 2.6.27 is a bit old, you might try :
>
> commit 7fa7cb7109d07c29ab28bb877bc7049a0150dbe5
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Mon Sep 27 04:18:27 2010 +0000
>   
Amazing -- a fix in 20 minutes -- thank you!  I need to do more load
testing but it looks like it may have solved the issue.

Joe Buehler


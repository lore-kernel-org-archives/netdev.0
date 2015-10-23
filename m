From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] Add ip rule save/restore
Date: Thu, 22 Oct 2015 23:39:42 -0700
Message-ID: <20151022233942.49576e78@xeon-e3>
References: <56261A6C.7050907@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Kirill Tkhai <ktkhai@odin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33503 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbJWGjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 02:39:36 -0400
Received: by pabrc13 with SMTP id rc13so109384783pab.0
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 23:39:35 -0700 (PDT)
In-Reply-To: <56261A6C.7050907@odin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2015 13:41:48 +0300
Kirill Tkhai <ktkhai@odin.com> wrote:

> This patch adds save and restore commands to "ip rule"
> similar the same is made in commit f4ff11e3e298 for "ip route".
> 
> The feature is useful in checkpoint/restore for container
> migration, also it may be helpful in some normal situations.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@odin.com>

Sure applied.

From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups
Date: Sun, 26 Apr 2009 15:33:28 +0200
Message-ID: <49F462A8.5060008@gmail.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>	<49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:41013 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbZDZNeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2009 09:34:05 -0400
Received: by bwz7 with SMTP id 7so1828114bwz.37
        for <netdev@vger.kernel.org>; Sun, 26 Apr 2009 06:34:02 -0700 (PDT)
In-Reply-To: <49F43B8F.2050907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 04/26/2009 12:46 PM:

...
> [PATCH] poll: Avoid extra wakeups in select/pol

...

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  fs/select.c          |   28 +++++++++++++++++++++++++---
>  include/linux/poll.h |    3 +++
>  2 files changed, 28 insertions(+), 3 deletions(-)


Eric, I wonder why you've forgotten about linux-kernel@ folks...

Jarek P.

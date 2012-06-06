From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH IPROUTE2] ss: Add support for sk_meminfo_backlog
Date: Wed, 6 Jun 2012 16:23:33 -0700
Message-ID: <20120606162333.52e1256d@nehalam.linuxnetplumber.net>
References: <1339024292-4361-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59177 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758916Ab2FFXXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 19:23:42 -0400
In-Reply-To: <1339024292-4361-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  6 Jun 2012 16:11:32 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> This adds the ability to print the backlog length of sockets that is provided by
> recent Linux kernels since commit (d594e987c6 sock_diag: add
> SK_MEMINFO_BACKLOG).
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Since the SK_MEMINFO_BACKLOG is not in 3.5 (it is in net-next);
please resubmit this when it is accepted in Linus's tree.

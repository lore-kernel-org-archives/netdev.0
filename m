From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute2: add support to monitor mdb entries too
Date: Wed, 12 Dec 2012 10:41:38 -0800
Message-ID: <20121212104138.2a927498@nehalam.linuxnetplumber.net>
References: <1355300590-2390-1-git-send-email-amwang@redhat.com>
	<1355300590-2390-4-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55414 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753949Ab2LLSnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 13:43:05 -0500
In-Reply-To: <1355300590-2390-4-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 16:23:10 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> This patch implements `bridge monitor mdb`.
> 
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 

Accepted for 3.8 since Dave accepted the kernel parts. Thanks

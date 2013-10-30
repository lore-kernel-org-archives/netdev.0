From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: add cls_bpf frontend
Date: Wed, 30 Oct 2013 16:46:39 -0700
Message-ID: <20131030164639.1c4ba51d@nehalam.linuxnetplumber.net>
References: <1382960133-2240-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:64417 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab3J3Xqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 19:46:43 -0400
Received: by mail-pb0-f42.google.com with SMTP id jt11so2115458pbb.1
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 16:46:42 -0700 (PDT)
In-Reply-To: <1382960133-2240-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Oct 2013 12:35:33 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> This is the iproute2 part of the kernel patch "net: sched:
> add BPF-based traffic classifier".
> 

Applied to net-next-3.11 branch

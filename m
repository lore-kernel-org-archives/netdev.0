From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 6/7] netlink: rename private flags and states
Date: Thu, 7 May 2015 13:49:56 +0200
Message-ID: <20150507114956.GB16619@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430989373-4515-7-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f65.google.com ([74.125.82.65]:35802 "EHLO
	mail-wg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbEGLt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 07:49:59 -0400
Received: by wggy19 with SMTP id y19so1384901wgg.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 04:49:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430989373-4515-7-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/15 at 11:02am, Nicolas Dichtel wrote:
> These flags and states have the same prefix (NETLINK_) that netlink socket
> options. To avoid confusion and to be able to name a flag like a socket
> option, let's use an other prefix: NETLINK_[S|F]_.
> 
> Note: a comment has been fixed, it was talking about
> NETLINK_RECV_NO_ENOBUFS socket option instead of NETLINK_NO_ENOBUFS.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@suug.ch>

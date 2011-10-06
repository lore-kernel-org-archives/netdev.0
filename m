From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/3] iproute2: various usage and doc fixes
Date: Thu, 6 Oct 2011 08:25:32 -0700
Message-ID: <20111006082532.0311b678@nehalam.linuxnetplumber.net>
References: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Sabata <contyk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40676 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758625Ab1JFPZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 11:25:35 -0400
In-Reply-To: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  6 Oct 2011 14:45:31 +0200
Petr Sabata <contyk@redhat.com> wrote:

> Petr Sabata (3):
>   iproute2: ss - fix missing parameters
>   iproute2: lnstat - fix typos
>   iproute2: arpd - fix usage and manpage options
> 
>  man/man8/arpd.8 |    4 ++--
>  man/man8/ss.8   |    4 ++--
>  misc/arpd.c     |    2 +-
>  misc/lnstat.c   |    4 ++--
>  misc/ss.c       |    6 ++++--
>  5 files changed, 11 insertions(+), 9 deletions(-)
> 

All applied. 

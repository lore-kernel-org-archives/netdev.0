From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/2 net-next] iproute2: VXLAN Group Policy extension
Date: Thu, 5 Feb 2015 10:32:56 -0800
Message-ID: <20150205103256.4dc91d48@urahara>
References: <cover.1421329802.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38809 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbBESc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:32:58 -0500
Received: by pdbft15 with SMTP id ft15so9297941pdb.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:32:57 -0800 (PST)
In-Reply-To: <cover.1421329802.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2015 14:54:24 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Stephen,
> 
> Against net-next branch. I assume you only want to apply patch 1/2 after
> the next header sync. I've included 2/2 if anyone wants to use it now and
> needs the header bits
> 
> Thomas Graf (2):
>   vxlan: Group policy extension
>   vxlan: synchronize <linux/if_link.h> header
> 
>  include/linux/if_link.h |  3 +++
>  ip/iplink_vxlan.c       | 11 +++++++++++
>  man/man8/ip-link.8.in   | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 59 insertions(+)
> 

I picked headers up in separate merge.

The iplink changes are waiting in net-next branch.

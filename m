From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/3] iplink: shortify printing the usage of
 bridge
Date: Wed, 12 Aug 2015 09:08:10 -0700
Message-ID: <20150812090810.2ee2aaef@urahara>
References: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35532 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbbHLQIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:08:07 -0400
Received: by pacgr6 with SMTP id gr6so17381664pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:08:07 -0700 (PDT)
In-Reply-To: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Aug 2015 06:03:21 +0000
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> This patch set enables bridge related links to print usage with short format.
> Or else it is needed to use the following way:
> 	    
>   ip link { add | del | set } type TYPE help
> 
> Zhang Shengju (3):
>   iplink: add missing link type
>   iplink: use the short format to print help info
>   iplink: shortify printing the usage of link type
> 
>  ip/iplink.c              |  2 +-
>  ip/iplink_bridge.c       | 16 ++++++++++++++--
>  ip/iplink_bridge_slave.c | 16 ++++++++++++++--
>  3 files changed, 29 insertions(+), 5 deletions(-)
> 

All 3 and the typo patch applied.

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: man: change man page and comment to confirm to
 code's behavior.
Date: Thu, 12 Jul 2012 09:06:20 -0700
Message-ID: <20120712090620.56d3cc38@nehalam.linuxnetplumber.net>
References: <4FFD2A42.9080507@cn.fujitsu.com>
	<20120711075129.4f81eea8@nehalam.linuxnetplumber.net>
	<4FFE2EE9.8030808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161252Ab2GLQGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 12:06:38 -0400
In-Reply-To: <4FFE2EE9.8030808@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jul 2012 09:56:57 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> 
> Since the get_rate() code incorrectly interpreted bare number, the
> behavior is not the same as man page and comment described.
> 
> We need to change the man page and comment for compatible with the
> existing usage by scripts.
> ---
>  man/man8/tc.8 |    7 +++++--
>  tc/tc_util.c  |    2 +-
>  2 files changed, 6 insertions(+), 3 deletions(-)

Thanks for fixing. Accepted.

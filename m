From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next v2 0/5] sctp: fix checkpatch errors
Date: Mon, 23 Dec 2013 08:31:00 -0500
Message-ID: <20131223133100.GB20864@hmsreliant.think-freely.org>
References: <1387772214-26068-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39320 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757193Ab3LWNbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 08:31:04 -0500
Content-Disposition: inline
In-Reply-To: <1387772214-26068-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 12:16:49PM +0800, Wang Weidong wrote:
> fix checkpatch errors.
> 
> v1 -> v2:
>   -patch1: add Neil's Ack
>   -patch2: fix the subject line which is not clearly pointed out by Neil
>   -patch3: add Neil's Ack
>   -patch4: fix the subject line and blurb which is not clearly pointed out by Neil
> 
> Wang Weidong (5):
>   sctp: fix checkpatch errors with space required or prohibited
>   sctp: fix checkpatch errors with (foo*)|foo * bar|foo* bar
>   sctp: fix checkpatch errors with indent
>   sctp: fix checkpatch errors with open brace '{' and trailing
>     statements
>   sctp: fix checkpatch errors with //commen
> 
>  net/sctp/auth.c          | 27 +++++++++---------
>  net/sctp/chunk.c         |  4 +--
>  net/sctp/input.c         | 58 +++++++++++++++++++--------------------
>  net/sctp/ipv6.c          |  2 +-
>  net/sctp/objcnt.c        |  2 +-
>  net/sctp/output.c        | 11 ++++----
>  net/sctp/outqueue.c      |  8 +++---
>  net/sctp/proc.c          |  8 +++---
>  net/sctp/protocol.c      |  4 +--
>  net/sctp/sm_make_chunk.c | 71 ++++++++++++++++++++++++------------------------
>  net/sctp/sm_sideeffect.c |  4 +--
>  net/sctp/sm_statefuns.c  | 27 +++++++++---------
>  net/sctp/sm_statetable.c |  2 +-
>  net/sctp/socket.c        | 53 ++++++++++++++++++------------------
>  net/sctp/sysctl.c        |  2 +-
>  net/sctp/ulpqueue.c      | 11 ++++----
>  16 files changed, 145 insertions(+), 149 deletions(-)
> 
> -- 
> 1.7.12
> 
> 
> 

for the series
Acked-by: Neil Horman <nhorman@tuxdriver.com>

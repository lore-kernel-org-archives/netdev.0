From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next v3 2/2] RDS: TCP: Remove unused constant
Date: Tue, 15 Mar 2016 12:22:02 -0700
Message-ID: <56E860DA.4060403@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <46e6ca62f49240021c7b91da101edaa1a5e978f9.1458064902.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34715 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932665AbcCOTWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 15:22:11 -0400
In-Reply-To: <46e6ca62f49240021c7b91da101edaa1a5e978f9.1458064902.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2016 11:53 AM, Sowmini Varadhan wrote:
> RDS_TCP_DEFAULT_BUFSIZE has been unused since commit 1edd6a14d24f
> ("RDS-TCP: Do not bloat sndbuf/rcvbuf in rds_tcp_tune").
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v3: review comments from Santosh Shilimkar
>
>   net/rds/tcp.c |    2 --
>   1 files changed, 0 insertions(+), 2 deletions(-)
>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

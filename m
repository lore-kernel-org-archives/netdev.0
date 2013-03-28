From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 5/6] scsi: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Thu, 28 Mar 2013 11:36:05 -0500
Message-ID: <51547175.409@cs.wisc.edu>
References: <1364403195-32839-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364403195-32839-1-git-send-email-honkiko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/27/2013 11:53 AM, Hong Zhiguo wrote:
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  drivers/scsi/scsi_netlink.c         |    4 +--
>  drivers/scsi/scsi_transport_fc.c    |   21 +++++--------
>  drivers/scsi/scsi_transport_iscsi.c |   56 +++++++++++++++++------------------
>  3 files changed, 38 insertions(+), 43 deletions(-)
> 

iscsi parts are ok. I also ran some quick tests on them.

Reviewed-by: Mike Christie <michaelc@cs.wisc.edu>

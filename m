From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 net-next repost 1/2] devlink: implement shared buffer
 support
Date: Mon, 16 May 2016 11:23:43 -0700
Message-ID: <20160516112343.1345e054@xeon-e3>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
	<1463232062-3708-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33749 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370AbcEPSXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:23:30 -0400
Received: by mail-pa0-f45.google.com with SMTP id xk12so67610819pac.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:23:30 -0700 (PDT)
In-Reply-To: <1463232062-3708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 May 2016 15:21:01 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Implement kernel devlink shared buffer interface. Introduce new object
> "sb" and allow to browse the shared buffer parameters and also change
> configuration.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  devlink/devlink.c | 653 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 652 insertions(+), 1 deletion(-)

Both applied to net-next

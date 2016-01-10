From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 2/8] bridge: Reflect MDB entries to hardware
Date: Sun, 10 Jan 2016 21:12:22 +0100
Message-ID: <5692BB26.7020008@cumulusnetworks.com>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
 <1452456389-2833-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33143 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185AbcAJUMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:12:24 -0500
Received: by mail-wm0-f41.google.com with SMTP id f206so191006585wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:12:24 -0800 (PST)
In-Reply-To: <1452456389-2833-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2016 09:06 PM, Jiri Pirko wrote:
> From: Elad Raz <eladr@mellanox.com>
> 
> Offload MDB changes per port to hardware
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br_mdb.c | 23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

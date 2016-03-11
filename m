From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 04/13] net/mlx5e: Use only close NUMA node for
 default RSS
Date: Fri, 11 Mar 2016 17:08:55 +0300
Message-ID: <56E2D177.3090403@cogentembedded.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
 <1457703594-9482-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35409 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067AbcCKOI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 09:08:59 -0500
Received: by mail-lb0-f178.google.com with SMTP id bc4so156891844lbc.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 06:08:58 -0800 (PST)
In-Reply-To: <1457703594-9482-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/11/2016 4:39 PM, Saeed Mahameed wrote:

> From: Tariq Toukan <tariqt@mellanox.com>
>
> Distribute default RSS table uniformely over the rings of the

    Uniformly.

> close NUMA node, instead of all available channels.
> This way we enforce the preference of close rings over far ones.
>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
[...]

MBR, Sergei

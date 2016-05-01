From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH v2 7/9] mlx5e: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Sun, 1 May 2016 23:08:12 +0300
Message-ID: <CALzJLG9dHq2Dd_noZrN10yxwM=ZJf9du5009O9=Cju25-pqWAg@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server> <20160429224345.12418.88876.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tal Alon <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	michael.chan@broadcom.com, "David S. Miller" <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34317 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbcEAUIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:08:32 -0400
Received: by mail-yw0-f193.google.com with SMTP id i22so16787979ywc.1
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:08:32 -0700 (PDT)
In-Reply-To: <20160429224345.12418.88876.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch assumes that the mlx5 hardware will ignore existing IPv4/v6
> header fields for length and checksum as well as the length and checksum
> fields for outer UDP headers.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>

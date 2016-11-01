From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net/mlx4_en: Add TX_XDP for CQ types
Date: Tue, 1 Nov 2016 13:57:06 +0200
Message-ID: <d8b10db9-4ec0-4d9d-c004-579f8fe0b0a3@mellanox.com>
References: <1478000186-5158-1-git-send-email-tariqt@mellanox.com>
 <1478000186-5158-2-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eran Ben Elisha <eranbe@mellanox.com>,
        "Brenden Blanco" <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0064.outbound.protection.outlook.com ([104.47.2.64]:64320
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1169178AbcKANaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 09:30:02 -0400
In-Reply-To: <1478000186-5158-2-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/01/2016 01:36 PM, Tariq Toukan wrote:
> Support XDP CQ type, and refactor the CQ type enum.
> Rename the is_tx field to match the change.
>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>

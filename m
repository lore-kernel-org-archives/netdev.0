From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: mpls: make function
 ipgre_mpls_encap_hlen static
Date: Wed, 11 Oct 2017 20:20:16 -0700 (PDT)
Message-ID: <20171011.202016.1730207765050552906.davem@davemloft.net>
References: <20171011095328.17546-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, rshearma@brocade.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20171011095328.17546-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 11 Oct 2017 10:53:28 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The function ipgre_mpls_encap_hlen is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol 'ipgre_mpls_encap_hlen' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks Colin.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipmr: ipmr_get_table() returns NULL
Date: Wed, 12 Jul 2017 08:19:11 -0700 (PDT)
Message-ID: <20170712.081911.723573255148721051.davem@davemloft.net>
References: <20170712075647.zyz6pkppyerl4ktf@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sharpd@cumulusnetworks.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170712075647.zyz6pkppyerl4ktf@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 12 Jul 2017 10:56:47 +0300

> The ipmr_get_table() function doesn't return error pointers it returns
> NULL on error.
> 
> Fixes: 4f75ba6982bc ("net: ipmr: Add ipmr_rtm_getroute")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.

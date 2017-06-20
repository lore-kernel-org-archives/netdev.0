From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/4] rtnetlink: add NEWCACHEREPORT message
 type
Date: Tue, 20 Jun 2017 11:54:16 +0300
Message-ID: <a65cada1-a796-33fc-018c-bbdbfdef7fb1@cumulusnetworks.com>
References: <20170619204417.13230-1-julien@arista.com>
 <20170619204417.13230-2-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619204417.13230-2-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/06/17 23:44, Julien Gomes wrote:
> New NEWCACHEREPORT message type to be used for cache reports sent
> via Netlink, effectively allowing splitting cache report reception from
> mroute programming.
> 
> Suggested-by: Ryan Halbrook <halbrook@arista.com>
> Signed-off-by: Julien Gomes <julien@arista.com>
> ---
>  include/uapi/linux/rtnetlink.h | 3 +++
>  security/selinux/nlmsgtab.c    | 3 ++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

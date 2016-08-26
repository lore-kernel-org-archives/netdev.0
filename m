From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V3 1/4] net/ip_tunnels: Introduce
 tunnel_id_to_key32() and key32_to_tunnel_id()
Date: Fri, 26 Aug 2016 12:26:16 +0200
Message-ID: <20160826122616.0f6e2d50@griffin>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
        <1472141627-27339-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52782 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753131AbcHZK0V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 06:26:21 -0400
In-Reply-To: <1472141627-27339-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Aug 2016 19:13:44 +0300, Hadar Hen Zion wrote:
> From: Amir Vadai <amir@vadai.me>
> 
> Add utility functions to convert a 32 bits key into a 64 bits tunnel and
> vice versa.
> These functions will be used instead of cloning code in GRE and VXLAN,
> and in tc act_iptunnel which will be introduced in a following patch in
> this patchset.
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Acked-by: Jiri Benc <jbenc@redhat.com>

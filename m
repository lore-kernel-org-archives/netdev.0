From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V2 1/4] net/ip_tunnels: Introduce
 tunnel_id_to_key32() and key32_to_tunnel_id()
Date: Wed, 24 Aug 2016 21:15:13 +0300
Message-ID: <20160824211513.256679cc@halley>
References: <20160824122710.30356-1-amir@vadai.me>
        <20160824122710.30356-2-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35890 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754059AbcHXSRE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:17:04 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so3689960wmf.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 11:15:24 -0700 (PDT)
In-Reply-To: <20160824122710.30356-2-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Aug 2016 15:27:07 +0300 Amir Vadai <amir@vadai.me> wrote:
> Add utility functions to convert a 32 bits key into a 64 bits tunnel and
> vice versa.
> These functions will be used instead of cloning code in GRE and VXLAN,
> and in tc act_iptunnel which will be introduced in a following patch in
> this patchset.
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

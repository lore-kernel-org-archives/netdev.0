From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: ethernet: renesas: ravb: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 20 Aug 2016 22:41:20 +0300
Message-ID: <f7ad11ff-179c-4d20-4115-1ce0522536dd@cogentembedded.com>
References: <1471647139-1867-1-git-send-email-tremyfr@gmail.com>
 <1471647139-1867-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net,
        kazuya.mizuguchi.ks@renesas.com, ykaneko0929@gmail.com,
        horms+renesas@verge.net.au, masaru.nagai.vx@renesas.com,
        geert+renesas@glider.be, niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471647139-1867-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/20/2016 01:52 AM, Philippe Reynes wrote:

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
[...]

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    Sorry for missing the sh_eth patchset. :-<

MBR, Sergei

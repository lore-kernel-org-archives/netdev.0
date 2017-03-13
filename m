From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/9] net: stmmac: Fixes and Tegra186 support
Date: Sun, 12 Mar 2017 23:35:37 -0700 (PDT)
Message-ID: <20170312.233537.550549154628879039.davem@davemloft.net>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org, jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, cyndis-/1wQRMveznE@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170310163501.31811-1-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 10 Mar 2017 17:34:52 +0100

> This series of patches start with a few cleanups that I ran across while
> adding Tegra186 support to the stmmac driver. It then adds code for FIFO
> size parsing from feature registers and finally enables support for the
> incarnation of the Synopsys DWC QOS IP found on NVIDIA Tegra186 SoCs.
> 
> This is based on next-20170310.
> 
> Changes in v2:
> - address review comments by Mikko and Joao
> - add two additional cleanup patches

Series applied, thank you.

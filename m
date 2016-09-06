From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 0/2] net: ethernet: mediatek: add
 enhancements to RX path
Date: Tue, 06 Sep 2016 13:33:34 -0700 (PDT)
Message-ID: <20160906.133334.2283994202447289212.davem@davemloft.net>
References: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472896767-18352-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Date: Sat, 3 Sep 2016 17:59:25 +0800

> Changes since v1:
> - fix message typos and add coverletter
>   
> Changes since v2:
> - split from the previous series for submitting add enhancements as 
> a series targeting 'net-next' and add indents before comments.
> 
> Changes since v3:
> - merge the patch using PDMA RX path
> - fixed the input of mtk_poll_rx is with the remaining budget
> 
> Changes since v4:
> - save one wmb and register update when no packet is being handled
> inside mtk_poll_rx call
> - fixed incorrect return packet count from mtk_napi_rx

Series applied.

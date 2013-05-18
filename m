From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] gianfar: add missing iounmap() on error in
 gianfar_ptp_probe()
Date: Fri, 17 May 2013 18:20:03 -0700 (PDT)
Message-ID: <20130517.182003.132169969783675734.davem@davemloft.net>
References: <CAPgLHd9ED7YCCTmKtD9PURq_cWy5GG=M+4ExC1wd+xOpgB97CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org,
 yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <CAPgLHd9ED7YCCTmKtD9PURq_cWy5GG=M+4ExC1wd+xOpgB97CQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 17 May 2013 16:25:34 +0800

> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> 
> Add the missing iounmap() before return from gianfar_ptp_probe()
> in the error handling case.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Applied, thanks.

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH v2] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Fri, 27 Oct 2017 15:56:35 -0500
Message-ID: <20171027155635.Horde.6xAuirEy6rlKFBxMNmJ2wmw@gator4166.hostgator.com>
References: <20171026054745.Horde.IgJuLhgV7tprdH0lZ5Pdj0U@gator4166.hostgator.com>
 <20171026113135.GA8044@embeddedor.com> <20171027104608.GE11292@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027104608.GE11292@secunet.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting Steffen Klassert <steffen.klassert@secunet.com>:

> On Thu, Oct 26, 2017 at 06:31:35AM -0500, Gustavo A. R. Silva wrote:
>> Use BUG_ON instead of if condition followed by BUG.
>>
>> This issue was detected with the help of Coccinelle.
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> Applied to ipsec-next, thanks Gustavo!

Glad to help. :)

Thank you
--
Gustavo A. R. Silva

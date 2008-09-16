From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] ipvs: change some __constant_htons() to htons()
Date: Tue, 16 Sep 2008 17:31:39 +0200
Message-ID: <f4845fc0809160831i6868459en6610a7e8b2204367@mail.gmail.com>
References: <48CFCC8F.1040702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <48CFCC8F.1040702@hp.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 16, 2008 at 5:11 PM, Brian Haley <brian.haley@hp.com> wrote:
> Change __contant_htons() to htons() in the IPVS code when not in an
> initializer.
>
> -Brian
>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Thanks. I somehow missed that in the patch series that got in,
although you mentioned it before, sorry!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1

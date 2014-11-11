From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: skbuff_fclone_cache poison overwritten
Date: Tue, 11 Nov 2014 22:33:29 +0000
Message-ID: <CALjAwxhVKBYO3TvAzgd_Oi5Cne1yFkvX5L=pzkfX3Rgcd7nL2g@mail.gmail.com>
References: <20141110113248.GA25131@sucs.org>
	<8a1a6be73725414cb3360011fa69581c@BL2PR03MB132.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Long Li <longli@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8a1a6be73725414cb3360011fa69581c@BL2PR03MB132.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 November 2014 19:27, Long Li <longli@microsoft.com> wrote:
> It's not obvious if this is a problem with hv_netvsc, or other code.
>
> Can you try to use a legacy network device and see if this issue still exists?

Good point - I'll try that tomorrow (your guess that I was currently
using non-legacy/paravirtualised network cards was right).

-- 
Sitsofe | http://sucs.org/~sits/

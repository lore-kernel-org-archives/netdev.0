From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 0/4] new ethernet address manipulation checks
Date: Sun, 26 Apr 2015 11:20:16 -0700
Message-ID: <1430072416.4833.10.camel@perches.com>
References: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(adding Andrew Morton)

On Sun, 2015-04-26 at 18:43 +0200, Mateusz Kulikowski wrote:
> Changes in v3:
> - Fixed handling of MEMSET issues (due to '/s' at the end the same 
>   error/warning was reported several times)
> - Added handling of multiline PREFER_ETHER_ADDR_COPY warnings
> - Review: added --fix option to eth_zero/broadcast_addr checks
> - All new warnings are multi-line aware (fixes work on single lines only)

Acked-by: Joe Perches <joe@perches.com>

Thanks Mateusz

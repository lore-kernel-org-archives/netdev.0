From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [PATCH 06/11] ipw2x00: Remove extern from function prototypes
Date: Thu, 26 Sep 2013 02:24:32 +0400
Message-ID: <CA++WF2PdHWvcsQtxaM-TLqqZ6PcU2uABeB-qnxmAC+FaQgHy0A@mail.gmail.com>
References: <cover.1380137609.git.joe@perches.com>
	<89eb744f1a77b32d6ec718618f356df3188403e7.1380137609.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <89eb744f1a77b32d6ec718618f356df3188403e7.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On 25 September 2013 23:37, Joe Perches <joe@perches.com> wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
>
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

Looks fine, thanks.

Stanislav.

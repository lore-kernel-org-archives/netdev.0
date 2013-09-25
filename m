From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 11/11] rtlwifi: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 18:01:06 -0500
Message-ID: <52436B32.4040109@lwfinger.net>
References: <cover.1380137609.git.joe@perches.com> <a958df5dc3065ce517726dc54087639e13ffee8f.1380137610.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a958df5dc3065ce517726dc54087639e13ffee8f.1380137610.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/25/2013 02:37 PM, Joe Perches wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
>
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
>
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry

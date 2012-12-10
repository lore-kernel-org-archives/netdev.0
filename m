From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RESEND] net: remove obsolete simple_strto<foo>
Date: Mon, 10 Dec 2012 10:03:41 -0500
Message-ID: <20121210150341.GD23628@hmsreliant.think-freely.org>
References: <1355130748-7828-1-git-send-email-abhi.c.pawar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Cong Wang <amwang@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-wireless@vger.kernel.org
To: Abhijit Pawar <abhi.c.pawar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1355130748-7828-1-git-send-email-abhi.c.pawar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 10, 2012 at 02:42:28PM +0530, Abhijit Pawar wrote:
> This patch replace the obsolete simple_strto<foo> with kstrto<foo>
> 
> Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

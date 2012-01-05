From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 2/7] rtlwifi: Standardize RT_PRINT_DATA macro and uses
Date: Thu, 5 Jan 2012 12:43:15 +0100
Message-ID: <20120105114314.GD2222@redhat.com>
References: <cover.1325734202.git.joe@perches.com>
 <e7d4163a9897f33145d8a07be54f507ab68e0243.1325734203.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e7d4163a9897f33145d8a07be54f507ab68e0243.1325734203.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe

On Wed, Jan 04, 2012 at 07:40:40PM -0800, Joe Perches wrote:
>  	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,

Since you are working on it, can you also get rid of this DBG_*
parameter, if rtlwifi maintainers are ok with that? It is additional
console loglvevel, standard kernel loglevel should be used.

Thanks
Stanislaw

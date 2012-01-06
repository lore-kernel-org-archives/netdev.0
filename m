From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/2] rtlwifi: Simplify chip version id logging
Date: Fri, 06 Jan 2012 14:57:01 -0600
Message-ID: <4F07601D.3050504@lwfinger.net>
References: <0f80cb0e369db8c8884d4a1d46e70a60c1dfb19c.1325878172.git.joe@perches.com> <066ccb110481f572dd34b5fc83671194f3d2e00a.1325878172.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <066ccb110481f572dd34b5fc83671194f3d2e00a.1325878172.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/06/2012 01:31 PM, Joe Perches wrote:
> Reduce object size a few KB too.
>
> $ size drivers/net/wireless/rtlwifi/built-in.o*
>     text	   data	    bss	    dec	    hex	filename
>   584493	  55333	 126800	 766626	  bb2a2	drivers/net/wireless/rtlwifi/built-in.o.new
>   586904	  55333	 127216	 769453	  bbdad	drivers/net/wireless/rtlwifi/built-in.o.old
>
> Signed-off-by: Joe Perches<joe@perches.com>

ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

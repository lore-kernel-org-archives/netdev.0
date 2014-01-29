From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/4] OpenCores 10/100 MAC ethtool operations
Date: Wed, 29 Jan 2014 12:01:57 -0800
Message-ID: <CAGVrzcZQLO5t=kmYtUoPBRZG=HrZQTxD8B0K-yN+h-z4ZCRL7A@mail.gmail.com>
References: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Marc Gauthier <marc@cadence.com>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-01-29 Max Filippov <jcmvbkbc@gmail.com>:
> Hello David, Florian and everybody,
>
> this series implements ethtool callbacks for the ethoc driver as was
> requested by Florian.

Thanks Max, this does look good to me now:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

>
> Max Filippov (4):
>   net: ethoc: implement basic ethtool operations
>   net: ethoc: implement ethtool get/set settings
>   net: ethoc: implement ethtool get registers
>   net: ethoc: implement ethtool get/set ring parameters
>
>  drivers/net/ethernet/ethoc.c | 85 ++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 85 insertions(+)
>
> --
> 1.8.1.4
>



-- 
Florian

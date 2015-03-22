From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/18] net: dsa: HW bridging, EEE support
Date: Sat, 21 Mar 2015 19:31:19 -0700
Message-ID: <550E2977.3070500@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>	<20150321.184817.575148530596089433.davem@davemloft.net>	<550DFADE.1080209@roeck-us.net> <20150321.221450.2007372852150941507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150321.221450.2007372852150941507.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/2015 07:14 PM, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Sat, 21 Mar 2015 16:12:30 -0700
>
>> Yes, agreed. It is on the to-do list. Should we be more aggressive ?
>> Since I'll have to resubmit anyway, we could start by adding defines
>> for all constants used in this patch set, not just some of them.
>
> As long as you'll really take care of this afterwards, you can take
> care of the defines after this series is integrated.
>
Definitely. But I agree with Andrew, I would prefer to do it
after this and Andrew's next set of patches has been accepted.

Guenter

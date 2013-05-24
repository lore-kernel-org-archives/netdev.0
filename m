From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/4] ppp_mppe: cleanup kernel log messages
Date: Thu, 23 May 2013 18:32:52 -0700 (PDT)
Message-ID: <20130523.183252.2126974375260355007.davem@davemloft.net>
References: <1369222373-7701-1-git-send-email-jorge@dti2.net>
	<1369222373-7701-3-git-send-email-jorge@dti2.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: jorge@dti2.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369222373-7701-3-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Date: Wed, 22 May 2013 13:32:52 +0200

> @@ -43,6 +43,8 @@
>   *                    deprecated in 2.6
>   */
>  
> +#define DEBUG
> +

You've got to be kidding me.  Don't do this.

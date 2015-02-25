From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Introduce dsa_is_port_initialized
Date: Wed, 25 Feb 2015 17:58:01 -0500 (EST)
Message-ID: <20150225.175801.572493941223276136.davem@davemloft.net>
References: <1424847723-31140-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424847723-31140-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 24 Feb 2015 23:02:02 -0800

> To avoid race conditions when using the ds->ports[] array,
> we need to check if the accessed port has been initialized.
> Introduce and use helper function dsa_is_port_initialized
> for that purpose and use it where needed.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.

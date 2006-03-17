From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: e1000 endianness bugs
Date: Thu, 16 Mar 2006 19:17:57 -0500
Message-ID: <441A0035.4040506@garzik.org>
References: <20060315.142628.28661597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cramerj@intel.com, john.ronciak@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752225AbWCQASA@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060315.142628.28661597.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 	return -E_NO_BIG_ENDIAN_TESTING;
> 
> [E1000]: Fix 4 missed endianness conversions on RX descriptor fields.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

applied

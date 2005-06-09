From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 23:15:54 +0200
Message-ID: <1118351754.5508.30.camel@laptopd505.fenrus.org>
References: <200506090909.55889.vda@ilport.com.ua>
	 <20050608.231657.59660080.davem@davemloft.net>
	 <20050609104205.GD3169@elf.ucw.cz>
	 <20050609.125324.88476545.davem@davemloft.net>
	 <42A8AE2A.4080104@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, pavel@ucw.cz, vda@ilport.com.ua,
        abonilla@linuxwireless.org, jgarzik@pobox.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <42A8AE2A.4080104@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-06-09 at 16:01 -0500, James Ketrenos wrote:
> I don't know if all the distributions have moved away from this model. 
> If they have and the devices are brought up regardless of link, then
> going back to delaying radio initialization until the open() is called
> is workable. 

wouldn't you want that anyway for power saving reasons?

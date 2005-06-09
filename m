From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 09:37:25 +0300
Message-ID: <200506090937.25634.vda@ilport.com.ua>
References: <200506090909.55889.vda@ilport.com.ua> <200506090925.07495.vda@ilport.com.ua> <20050608.232818.31644993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: abonilla@linuxwireless.org, pavel@ucw.cz, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050608.232818.31644993.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 09 June 2005 09:28, David S. Miller wrote:
> From: Denis Vlasenko <vda@ilport.com.ua>
> Date: Thu, 9 Jun 2005 09:25:07 +0300
> 
> > You need to up interface? And surely you need ip addr? That's a knob also! :)
> 
> There's this thing called DHCP which takes care of this for me.
> With IPV6, even less configuration can be necessary.

But DHCP does not start by itself, and it shuldn't.
You start dhcp client. That is a "minimal config" in this case.

Anyway, I think I start trolling... I should stop now.
--
vda

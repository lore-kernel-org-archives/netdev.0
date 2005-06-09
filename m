From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 10:36:00 +0200
Message-ID: <20050609083600.GE1478@wiggy.net>
References: <200506090909.55889.vda@ilport.com.ua> <200506090925.07495.vda@ilport.com.ua> <20050608.232818.31644993.davem@davemloft.net> <200506090937.25634.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, abonilla@linuxwireless.org,
        pavel@ucw.cz, jgarzik@pobox.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200506090937.25634.vda@ilport.com.ua>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Denis Vlasenko wrote:
> But DHCP does not start by itself, and it shuldn't.

It does in most modern distros as far as I know. They use ifplugd or a
similar tool to monitor link status and configure the interface if a link is
detected.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.

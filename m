From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: Re: [IPv6] policy routing ?
Date: Wed, 06 Apr 2005 21:36:52 +0200
Message-ID: <42543A54.7030504@6wind.com>
References: <20050406100401.0eab9374.didier@barvaux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Didier Barvaux <didier@barvaux.org>
In-Reply-To: <20050406100401.0eab9374.didier@barvaux.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Didier Barvaux wrote:
> Hello,
> 
> 
> I'm trying to do policy routing with IPv6 (source routing) on a 2.6.11 kernel. It works perfectly well with IPv4 using iproute2 (iproute2-2.6.11-050330), but it doesn't seem to work with IPv6.

Hi Didier,
I beleive policy routing for IPv6 is not yet supported in the kernel.
FYI a patch is included in the implementation of Mobile IPv6 provided by 
MIPL: http://www.mobile-ipv6.org/
Online patch is based on 2.6.8.1.

Regards,

Jean-Mickael

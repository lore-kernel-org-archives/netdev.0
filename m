From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 7/9] net/eipoib: Add main driver functionality
Date: Thu, 19 Jul 2012 19:21:55 +0300
Message-ID: <50083423.2090407@mellanox.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>   <1342609202-32427-8-git-send-email-ogerlitz@mellanox.com>  <1342705789.2617.15.camel@bwh-desktop.uk.solarflarecom.com>  <50082BDE.2040005@mellanox.com> <1342714574.2617.43.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>,
	"Erez Shitrit" <erezsh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:59576 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751611Ab2GSQWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 12:22:08 -0400
In-Reply-To: <1342714574.2617.43.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/2012 7:16 PM, Ben Hutchings wrote:
> On Thu, 2012-07-19 at 18:46 +0300, Or Gerlitz wrote:
> For that end, I was under the impression all the three  NETIF_F_HW_VLAN_{TX,RX,FILTER) features need to be advertized. From your comment I understand now that RX/TX are enough in that respect?
> [...]
>
> Yes.

OK, good, will fix.

Or.

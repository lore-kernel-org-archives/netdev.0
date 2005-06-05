From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Mon, 06 Jun 2005 05:59:20 +0930
Message-ID: <42A360A0.1040902@aarnet.edu.au>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com> <20050531105939.7486e071@dxpl.pdx.osdl.net> <92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com> <20050601144123.2bc11c06@dxpl.pdx.osdl.net> <9A2D608A-D818-455B-96F4-ED42413556C0@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, Netdev <netdev@oss.sgi.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <9A2D608A-D818-455B-96F4-ED42413556C0@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Operationally, it would be very useful if the PHY printed
the physical interface detail when detected (1000Base-LX,
etc).

Also, it would be nice to be able to retrieve PHY data
independent of the interface status (eg, to retrieve
asset serial numbers, GBIC make/models, etc).

-- 
  Glen Turner         Tel: (08) 8303 3936 or +61 8 8303 3936
  Australia's Academic & Research Network  www.aarnet.edu.au

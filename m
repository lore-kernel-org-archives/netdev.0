From: Ricky lloyd <ricky.lloyd@gmail.com>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 17:34:20 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1a50bd3704101105046e66538c@mail.gmail.com>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
	 <416A7484.1030703@portrix.net>
Reply-To: Ricky lloyd <ricky.lloyd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cal Peake <cp@absolutedigital.net>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org,
        hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Dittmer <j.dittmer@portrix.net>
In-Reply-To: <416A7484.1030703@portrix.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Isn't the correct fix to declare iobase as (void __iomem *) ?
> 

Earlier today i had posted a patch which mainly fixes this same
problem with lotsa scsi
drivers and tulip drivers. I wondered the same "shouldnt all the addrs
be declared as
void __iomem* ??". 

-- 
-> Ricky

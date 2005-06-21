From: Feyd <feyd@nmskb.cz>
Subject: Re: ipw2100: firmware problem
Date: Tue, 21 Jun 2005 10:29:21 +0200
Message-ID: <20050621102921.5a8c953a@alfa.nmskb.cz>
References: <20050608142310.GA2339@elf.ucw.cz>
	<200506081744.20687.vda@ilport.com.ua>
	<20050608145653.GA8844@dwarf.suse.cz>
	<42B7C4D0.9070809@thekelleys.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jirka Bohac <jbohac@suse.cz>, Denis Vlasenko <vda@ilport.com.ua>,
        Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kelley <simon@thekelleys.org.uk>
In-Reply-To: <42B7C4D0.9070809@thekelleys.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Jun 2005 08:42:08 +0100
Simon Kelley <simon@thekelleys.org.uk> wrote:

> The atmel driver includes a small firmware stub which does nothing but 
> determine the MAC address, to solve this problem. This is compiled into 

Does it power-down the card after reading the MAC?

Feyd

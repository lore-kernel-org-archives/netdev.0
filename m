From: David Vrabel <dvrabel@arcom.com>
Subject: Re: iproute2 and 2.6.9 kernel headers (was Re: [ANNOUNCE] iproute2
 2.6.9-041019)
Date: Wed, 20 Oct 2004 12:52:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4176517C.4090504@arcom.com>
References: <41758014.4080502@osdl.org>	 <Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>	 <20041020070017.GA19899@sunbeam.de.gnumonks.org>	 <20041020094123.GF19899@sunbeam.de.gnumonks.org> <1098268885.3872.81.camel@baythorne.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>,
        Jeff Chua <jeffchua@silk.corp.fedex.com>,
        Stephen Hemminger <shemminger@osdl.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, LARTC@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1098268885.3872.81.camel@baythorne.infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> 
> The time has come to fix it properly instead. Anything which these tools
> actually need from the kernel headers should be moved into a separate
> header file (still in the kernel source) which is usable from _both_
> kernel and userspace.

Isn't this what linux-libc-headers is for?

> It should use standard types (like uint16_t etc)

Why doesn't the kernel use these standard types also?

David Vrabel
--
David Vrabel, Design Engineer

Arcom, Clifton Road           Tel: +44 (0)1223 411200 ext. 3233
Cambridge CB1 7EA, UK         Web: http://www.arcom.com/

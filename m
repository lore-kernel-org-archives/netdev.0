From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [netdrvr] netdev-2.6 queue updated
Date: Mon, 15 Nov 2004 12:08:09 -0500
Message-ID: <4198E279.5070806@pobox.com>
References: <20041115064609.GA14547@havoc.gtf.org> <20041115074949.GA9481@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20041115074949.GA9481@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wichert Akkerman wrote:
> Hi Jeff,
> 
> Previously Jeff Garzik wrote:
> 
>>The most notable thing is the addition of HostAP.
> 
> 
> I was expecting to see that pulled in through the wireless tree; does
> this have any affect on that tree?

It was pulled in through the wireless tree,

	wireless-2.6 -> netdev-2.6 -> -mm -> (eventually) upstream

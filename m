From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netdev-2.6 queue updated
Date: Wed, 20 Oct 2004 18:33:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4176E7BE.5020409@pobox.com>
References: <20041016010036.GA32213@havoc.gtf.org> <20041020174853.GA11659@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20041020174853.GA11659@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Hering wrote:
>  On Fri, Oct 15, Jeff Garzik wrote:
> 
> 
>> drivers/net/typhoon.c                         |  232 +++----
> 
> 
>>Jeff Garzik:
>>  o Hand-merge typhoon conflicts
>>  o [netdrvr eepro100] fix pci_iomap() args and info msg that follows
>>  o [netdrvr b44] update MODULE_AUTHORS
>>  o [netdrvr 8139cp] TSO support
>>  o [netdev] Remove no-op in-driver implementations of ->set_config()
> 
> 
> Current Linus tree does not compile.

Andrew already fixed.  Thanks for reporting though...

	Jeff

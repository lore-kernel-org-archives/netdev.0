From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netdev-2.6 queue updated
Date: Fri, 07 Jan 2005 14:11:33 -0500
Message-ID: <41DEDEE5.5020908@pobox.com>
References: <41DE73B5.6080303@pobox.com> <20050107190426.GA17017@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050107190426.GA17017@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>  o r8169: oversized driver field for ethtool
>>  o r8169: reduce max MTU for large frames
>>  o r8169: Large Send enablement
>>  o r8169: C 101
>>  o r8169: missing netif_poll_enable and irq ack
> 
> 
> Imho you can push these changes to mainline (with due credit to
> Jon D Mason for its contributions).

Yep, it's going in the next batch.  Most of netdev-2.6 is bound for 
mainline "soon".

	Jeff

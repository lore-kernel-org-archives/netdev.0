From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [8/14] Orinoco driver updates - PCMCIA initialization cleanups
Date: Thu, 24 Feb 2005 02:29:05 -0500
Message-ID: <421D8241.9020608@pobox.com>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <20050224040024.GI32001@localhost.localdomain> <20050224040052.GJ32001@localhost.localdomain> <20050224065527.GA8931@isilmar.linta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>,
        Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
In-Reply-To: <20050224065527.GA8931@isilmar.linta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dominik Brodowski wrote:
>>@@ -184,6 +186,7 @@
>> 	dev_list = link;
>> 
>> 	client_reg.dev_info = &dev_info;
>>+	client_reg.Attributes = INFO_IO_CLIENT | INFO_CARD_SHARE;
> 
> 
> That's not needed any longer for 2.6.

So who wants to send the incremental update patch?  :)

	Jeff

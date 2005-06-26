From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: BCM5721(tg3)&MSI
Date: Sat, 25 Jun 2005 20:47:39 -0400
Message-ID: <42BDFB2B.5000103@pobox.com>
References: <Pine.LNX.4.62.0506260116440.16847@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.62.0506260116440.16847@bizon.gios.gov.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:
> Hello,
> 
> Which BCM chips support MSI? I have a mainbord with two BCM5721, it 
> seems both support MSI (Message Signalled Interrupts entry in 
> Capabilities) but with 2.6.12.1 tg3 driver does not enable it. Why?

Most likely, your system doesn't support MSI?

	Jeff

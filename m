From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH wireless-2.6 0/12] Host AP update
Date: Tue, 09 Nov 2004 10:26:37 -0500
Message-ID: <4190E1AD.8000405@pobox.com>
References: <20041108070156.GA1076@jm.kir.nu> <41907A06.2040702@pobox.com> <41908932.6070900@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Renzmann <mrenzmann@web.de>
In-Reply-To: <41908932.6070900@web.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Renzmann wrote:
> Hi.
> 
> (I cutted down the CC list.)
> 
> Jeff Garzik wrote:
> 
>> A key goal I have for HostAP is that portions of HostAP code should be 
>> bundled into a generic "lib80211" kernel module, for use by various 
>> low-level and "softmac" 802.11 device drivers.
> 
> 
> This sentence made me curious... does that mean the efforts which 
> recently have been discussed here (to bring a generic 802.11 stack to 
> the kernel) are going to be replaced by the described goal? Or is it an 
> addition to Vladimir's work?

Hopefully Vladmir's work will plug right in..  I hope he's still working 
on it!

	Jeff

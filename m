From: Michael Renzmann <mrenzmann@web.de>
Subject: Re: [PATCH wireless-2.6 0/12] Host AP update
Date: Tue, 09 Nov 2004 10:09:06 +0100
Message-ID: <41908932.6070900@web.de>
References: <20041108070156.GA1076@jm.kir.nu> <41907A06.2040702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41907A06.2040702@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

(I cutted down the CC list.)

Jeff Garzik wrote:
> A key goal I have for HostAP is that portions of HostAP code should be 
> bundled into a generic "lib80211" kernel module, for use by various 
> low-level and "softmac" 802.11 device drivers.

This sentence made me curious... does that mean the efforts which 
recently have been discussed here (to bring a generic 802.11 stack to 
the kernel) are going to be replaced by the described goal? Or is it an 
addition to Vladimir's work?

Bye, Mike

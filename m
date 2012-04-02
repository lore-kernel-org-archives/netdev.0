From: Mirko Lindner <mlindner@marvell.com>
Subject: Re: one pci_id missing in sky2 driver
Date: Mon, 02 Apr 2012 12:24:14 +0200
Message-ID: <4478154.IuQcNxn3IZ@mlindner-lin>
References: <4F763075.7040402@gmail.com> <20120401122235.714dab09@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Xose Vazquez Perez <xose.vazquez@gmail.com>,
	David Miller <davem@davemloft.net>,
	Hardy Bastian <hbastian@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:51515 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752154Ab2DBKYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 06:24:44 -0400
In-Reply-To: <20120401122235.714dab09@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Stephen. The ID belongs to our newest device. We'll include the code 
into the driver and send a patch to the list as soon the driver has passed our 
internal tests.

- Mirko

On Sunday, April 01, 2012 12:22:35 PM Stephen Hemminger wrote:
> I would like to use this opportunity to have the developers at Marvell, test
> and submit this. They have the hardware (I don't) and often new chips
> require other special tweaks.  Marvell expressed interest in taking over
> maintaining the sky2 driver, this would be a good first step.

From: "Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>
Subject: Re: [PATCH net-next] ipheth: Add support for iPad 2 and iPad 3
Date: Tue, 3 Jun 2014 18:31:08 +0000
Message-ID: <EE5FBFB4-E1DD-47BF-8169-FCC4F51839D5@cisco.com>
References: <1401445020-14027-1-git-send-email-kristian.evensen@gmail.com>
 <20140602.161217.1136496149550873922.davem@davemloft.net>
 <CAKfDRXiQvteVXwHMaQxKbtDTb7v0OAx3dyN0WF6dTxKveN8GBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-1.cisco.com ([173.37.142.88]:35915 "EHLO
	alln-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbaFCSkl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 14:40:41 -0400
In-Reply-To: <CAKfDRXiQvteVXwHMaQxKbtDTb7v0OAx3dyN0WF6dTxKveN8GBg@mail.gmail.com>
Content-Language: en-US
Content-ID: <37063F6A142D674A8FD97B6803523925@emea.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 2, 2014, at 10:47 PM, Kristian Evensen <kristian.evensen@gmail.com> wrote:

> Btw, if anyone could do me a favor, I would appreciate it very much. I
> was told that the CDMA iPads have different PIDs than the GSM models,
> but I have not been able to confirm this. If anyone has a CDMA iPad,
> could you please check the PID and let me know?

http://www.linux-usb.org/usb.ids says this, if it helps.

	12a2  iPad 2 (3G; 64GB)
	12a3  iPad 2 (CDMA)
	12a4  iPad 3 (wifi)
	12a5  iPad 3 (CDMA)
	12a6  iPad 3 (3G, 16 GB)
	12a9  iPad 2
	12ab  iPad 4 (WiFi, 32GB)

Regards.

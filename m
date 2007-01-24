From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: dscape doesn't auto associate
Date: Wed, 24 Jan 2007 09:31:22 -0600
Message-ID: <45B77BCA.20000@lwfinger.net>
References: <9e4733910701231523w1de82215g6a142ed1e691674b@mail.gmail.com>	 <200701231843.05902.flamingice@sourmilk.net>	 <9e4733910701231748ve5817d1md0710c9d08934a0f@mail.gmail.com> <1169643079.2807.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jon Smirl <jonsmirl@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	netdev <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:57857 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbXAXPeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 10:34:20 -0500
In-Reply-To: <1169643079.2807.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> 
> If you get this error in the _NM_ logs, it's likely just trying to clear
> out the key, and you can probably ignore it.  If you get this error from
> wpa_supplicant, it's probably a driver issue.
> 
> Can you send me some logs privately?  I think SUSE directs the NM logs
> somewhere like /var/log/NetworkManager.log.  Stop NM as a service, get
> root, then "NetworkManager --no-daemon" and redirect the output to a
> file if you don't want to track down the logs themselves.

The log is in /var/log/NetworkManager on openSUSE 10.2.

Using bcm43xx-softmac, the returned frequency is 0. Any suggestions on where I should look to get
the proper frequency or channel data?

Larry



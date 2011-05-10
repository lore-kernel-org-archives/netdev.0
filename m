From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
Date: Tue, 10 May 2011 10:09:29 +0800
Message-ID: <883AEB89D11D495A9666E2F73C2CD95F@realtek.com.tw>
References: <1304928149-2201-1-git-send-email-hayeswang@realtek.com> <1304929425.12237.15.camel@i7.infradead.org> <20110509192309.GA20763@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'David Woodhouse' <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:44359 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775Ab1EJCJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 22:09:46 -0400
In-Reply-To: <20110509192309.GA20763@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, May 10, 2011 3:23 AM
> To: David Woodhouse
> Cc: Hayeswang; netdev@vger.kernel.org
> Subject: Re: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
> 
> David Woodhouse <dwmw2@infradead.org> :
> [...]
> > I'd be a lot happier if the WHENCE file contained version numbers. 
> > Does the *driver* print a version string for the firmware 
> after loading it?
> 
> No.
> 
> Hayes, do we agree that the firmware needs to embed a version 
> identifier (and some checksum to identify the current 
> firmware that don't embed one).
> 

I agree that. However, I have no idea about making it compatible with previous
parser and firmware. Let me think if there is a good way to do this.

Best Regards,
Hayes


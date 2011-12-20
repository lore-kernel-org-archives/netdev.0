From: hayeswang <hayeswang@realtek.com>
Subject: RE: [linux-firmware v6 2/4] rtl_nic: add new firmware for RTL8111F
Date: Tue, 20 Dec 2011 14:52:03 +0800
Message-ID: <0BDED3C1D85A4D43BD15E71992B7366E@realtek.com.tw>
References: <1319634425-1529-1-git-send-email-hayeswang@realtek.com> <1319634425-1529-2-git-send-email-hayeswang@realtek.com> <81662BFCE8FC4C70A9260DE3A1A52B78@realtek.com.tw> <1324012690.2825.271.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <dwmw2@infradead.org>, <romieu@fr.zoreil.com>,
	<netdev@vger.kernel.org>
To: 'Ben Hutchings' <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58211 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab1LTGwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 01:52:40 -0500
In-Reply-To: <1324012690.2825.271.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings [mailto:ben@decadent.org.uk] 
> Sent: Friday, December 16, 2011 1:18 PM
> To: Hayeswang
> Cc: dwmw2@infradead.org; romieu@fr.zoreil.com; netdev@vger.kernel.org
> Subject: RE: [linux-firmware v6 2/4] rtl_nic: add new 
> firmware for RTL8111F
> 
> On Thu, 2011-11-17 at 20:16 +0800, hayeswang wrote:
> > 
> > > -----Original Message-----
> > > From: Hayeswang [mailto:hayeswang@realtek.com] 
> > > Sent: Wednesday, October 26, 2011 9:07 PM
> > > To: dwmw2@infradead.org; ben@decadent.org.uk
> > > Cc: romieu@fr.zoreil.com; netdev@vger.kernel.org; Hayeswang
> > > Subject: [linux-firmware v6 2/4] rtl_nic: add new firmware 
> > > for RTL8111F
> > > 
> 
> Sorry Hayes, these were held up due to the rebuiling of kernel.org
> services.
> 
> I already applied your earlier changes (v0.0.2 of the 8186E and 8186F
> firmware) locally.  I have rebased this series of 4 patches on top of
> that, and pushed the result out.  Please check that I got it right.
> 

Thanks you very much. They are all right. Besides, should I change the
repository from
	http://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git
to
	
http://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
for reference? I don't see any update for the original repository to which the
document of kernel says to submit firmware.
 
Best Regards,
Hayes

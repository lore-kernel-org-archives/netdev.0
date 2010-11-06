From: Nikola Ciprich <extmaillist@linuxbox.cz>
Subject: Re: 2.6.36 vlans & bridge crash - status?
Date: Sat, 6 Nov 2010 08:11:15 +0100
Message-ID: <20101106071115.GA3264@nik-comp.lan>
References: <20101105103520.GA3577@pcnci.linuxbox.cz> <AANLkTin130xsLRQRMH2W6Yy=gJSD-qS29vR-E6Qvfgpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev list <netdev@vger.kernel.org>, nikola.ciprich@linuxbox.cz
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:56237 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753662Ab0KFHLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Nov 2010 03:11:19 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTin130xsLRQRMH2W6Yy=gJSD-qS29vR-E6Qvfgpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jesse,
It really fixes the problem, thanks!
Was the patch submitted to Greg for 2.6.36.y ?
n.


On Fri, Nov 05, 2010 at 08:05:17AM -0700, Jesse Gross wrote:
> On Fri, Nov 5, 2010 at 3:35 AM, Nikola Ciprich <extmaillist@linuxbox.cz> wrote:
> > Hello,
> > I would like to ask if somebody is trying to solve
> > https://bugzilla.kernel.org/show_bug.cgi?id=20462
> > and if needed, could I provide some help, testing etc?
> 
> I sent out a patch for something related:
> http://permalink.gmane.org/gmane.linux.network/176566
> 
> My guess is that it will also fix your issue.  Can you test it?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799

www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

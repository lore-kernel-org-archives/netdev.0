From: "Alex Deucher" <alexdeucher@gmail.com>
Subject: Marvell Libertas wifi
Date: Thu, 7 Dec 2006 12:32:34 -0500
Message-ID: <a728f9f90612070932x72e1d25u82ed3ea92984ccfc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:8523 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162574AbWLGRcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 12:32:41 -0500
Received: by ug-out-1314.google.com with SMTP id 44so526564uga
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 09:32:40 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just wanted to check on the status of the libertas driver from
Marvell for the OLPC project.  I haven't really been able to find out
much about this driver other than the commits to the olpc and
infradead libertas git trees.  The olpc laptop uses the usb interface
and that seems to be what is supported at the moment (although some
comments in the code allude to pci and sdio interfaces as well).  Does
anyone know what the plan is for merging this driver into mainline?
What about pci support?  Did Marvell donate any code for the PCI
interface? If not how hard would it be to add PCI support?  I
requested databooks from Marvell months ago, but never got anywhere.
I'd like to see better support for this chip and would be willing to
help out.  Any updates would be much appreciated.

Thanks,

Alex

PS, please CC: me on replies as I'm not on this list.

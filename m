From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream inclusion
Date: Thu, 22 Jun 2006 00:06:11 +0200
Message-ID: <20060621220611.GA31353@electric-eye.fr.zoreil.com>
References: <0BB3E5E7462EEA4295BC02D49691DC07176751@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, linux-driver@qlogic.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56739 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1030337AbWFUWKi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 18:10:38 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
Content-Disposition: inline
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC07176751@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer <ron.mercer@qlogic.com> :
[...]
> Please add the qla3xxx NIC driver to the next netdev-2.6 GIT tree. 

$ less qla3xxxpatch1-v2.02.00-k31.txt
[...]
+ * See LICENSE.qla3xxx for copyright and licensing details.

1 - The patch contains no such file (though the file is MODULE_LICENSE("GPL")).
    Please fix it.

2 - The description of the patch contains no Signed-off-by: attribute
    as per Documentation/SubmittingPatches. Can you send one ?

-- 
Ueimor

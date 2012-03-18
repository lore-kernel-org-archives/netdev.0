From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [net-next 8/9] bnx2x: consistent statistics for old FW
Date: Sun, 18 Mar 2012 16:52:04 -0400
Message-ID: <4F664AF4.3050402@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
 <1332102825-7838-9-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1886 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab2CROGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 10:06:48 -0400
Received: from lb-tlvb-yuvalmin.il.broadcom.com (
 lb-tlvb-yuvalmin.il.broadcom.com [10.185.6.94]) by
 mail-irva-13.broadcom.com (Postfix) with ESMTP id 3D275BC394 for
 <netdev@vger.kernel.org>; Sun, 18 Mar 2012 07:06:27 -0700 (PDT)
In-Reply-To: <1332102825-7838-9-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Previously applied patch making the bnx2x statistics consistent

> did not apply to old FWs. This remedies it, extending the consistent
> behaviour to all drivers.

Oops, forgot to thank Michal for finding this one.
Reported-by: Michal Schmidt <mschmidt@redhat.com>

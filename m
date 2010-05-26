From: "Venugopal Busireddy" <venu@nextio.com>
Subject: Re: [net-next PATCH] be2net: Adding PCI SRIOV support
Date: Wed, 26 May 2010 12:55:36 -0500
Message-ID: <5AC56E9F58E6EE4681447596FAECEC6DAA6506@ad-1.austin.nextio>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay-8.dlfw.twtelecom.net ([216.136.82.77]:33309 "EHLO
	relay-8.dlfw.twtelecom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752146Ab0EZSGn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 14:06:43 -0400
Received: from localhost (unknown [127.0.0.1])
	by relay-8.dlfw.twtelecom.net (Postfix) with ESMTP id B8BE1C0094
	for <netdev@vger.kernel.org>; Wed, 26 May 2010 11:55:38 -0600 (MDT)
Received: from relay-8.dlfw.twtelecom.net ([127.0.0.1])
	by localhost (relay-8.dlfw.twtelecom.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sVKgzqxRYMEd for <netdev@vger.kernel.org>;
	Wed, 26 May 2010 11:55:35 -0600 (MDT)
Received: from ad-1.austin.nextio (unknown [207.71.25.106])
	by relay-8.dlfw.twtelecom.net (Postfix) with ESMTP id C2B96C0082
	for <netdev@vger.kernel.org>; Wed, 26 May 2010 11:55:35 -0600 (MDT)
Content-class: urn:content-classes:message
In-Reply-To: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,
>> From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
>> Date: Wed, 31 Mar 2010 18:26:12 +0530
>> - Patch adds support to enable PCI SRIOV in the driver and changes to
handle \
>>                initialization of PCI virtual functions.
>> - Function handler to change mac addresses for VF from its
corresponding PF.
>> 
>> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
>Applied, thanks.
 I checked the 2.6.34 kernel, and could not see this patch applied in
it. In which kernel would this patch be available? Also, if I were to
apply this patch, which kernel version would this patch require?
Thanks,
Venu

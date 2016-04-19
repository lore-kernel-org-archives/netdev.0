From: "Butler, Peter" <pbutler@sonusnet.com>
Subject: RE: Poorer networking performance in later kernels?
Date: Tue, 19 Apr 2016 16:00:07 +0000
Message-ID: <SN1PR0301MB19986C8006021D89A562B94FD66C0@SN1PR0301MB1998.namprd03.prod.outlook.com>
References: <SN1PR0301MB19987565B71A4688593A2CDBD6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <SN1PR0301MB19983946D7A38001E4B54D20D6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <57116D21.8000807@hpe.com>
 <BY2PR0301MB1990F3095CFA07EBBE600F9DD66B0@BY2PR0301MB1990.namprd03.prod.outlook.com>
 <57152600.7000801@hpe.com>
 <SN1PR0301MB19983F545852731CD1410DB9D66C0@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <5716558B.2080103@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Rick Jones <rick.jones2@hpe.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0091.outbound.protection.outlook.com ([65.55.169.91]:7476
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932859AbcDSQAL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:00:11 -0400
In-Reply-To: <5716558B.2080103@hartkopp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the issue is resolved.  I had to recompile my 4.4.0 kernel with a few options pertaining to the Intel NIC which somehow (?) got left out or otherwise clobbered when I ported my 3.4.2 .config to the 4.4.0 kernel source tree.  With those changes now in I see essentially identical performance with the two kernels.  Sorry for any confusion and/or waste of time here.  My bad.
>

Can you please send the relevant changes in the config that caused the discussed issue?

Just in the case other people do a similar kernel upgrade from 3.x to a recent kernel and the current defaults lead to this non-optimal result.

Thanks,
Oliver


Yes I just replied to another email on this thread asking the same thing and posted some info.

Cheers,

Peter

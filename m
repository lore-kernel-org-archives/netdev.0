From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v3 net-next 0/6] bnx2x: refactor nvram related code
 and update version
Date: Mon, 22 Apr 2013 13:35:50 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20C0B581@SJEXCHMB06.corp.ad.broadcom.com>
References: <1366625708-5678-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4583 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455Ab3DVNgD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 09:36:03 -0400
In-Reply-To: <1366625708-5678-1-git-send-email-dmitry@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series includes checkpatch warnings In [4/6]
I will provide V4 very soon

> -----Original Message-----
> From: Dmitry Kravkov [mailto:dmitry@broadcom.com]
> Sent: Monday, April 22, 2013 1:15 PM
> To: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein
> Cc: romueu@fz.zoreil.com; Dmitry Kravkov
> Subject: [PATCH v3 net-next 0/6] bnx2x: refactor nvram related code and update version
> 
> Hi Dave,
> 
> Please cosider appliyng the series to net-next.
> 
> Changes for v2->v3:
> 1/4 	* was separated into 3 patches [1-3/6] pointed out by Francois Romieu
> 	* some cosmetics and beautifications was applied.
> 	* bnx2x_nvram_read32 rearranged according to Francois Romieu's comments
> 
> 2/4	* move to be 4/6
> 	* some code were extracted into fuctions in order to stop processing
>           once error was detected.
> 	* removed inaccurate decoding of errors - left only error messages
>           according to Francois Romieu's comments
> 	* removed useless init according to Francois Romieu's comment
> 
> Thanks
> Dmitry
> 

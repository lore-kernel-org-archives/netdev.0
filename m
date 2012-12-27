From: "Qin, Xiaohong" <Xiaohong.Qin@emc.com>
Subject: vxlan in Linux kernel 3.7
Date: Thu, 27 Dec 2012 13:42:51 -0500
Message-ID: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12B@MX01A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hop-nat-141.emc.com ([168.159.213.141]:27909 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751913Ab2L0SnJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 13:43:09 -0500
Received: from hop04-l1d11-si01.isus.emc.com (HOP04-L1D11-SI01.isus.emc.com [10.254.111.54])
	by mexforward.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id qBRIh8wr006523
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 13:43:08 -0500
Received: from mailhub.lss.emc.com (mailhubhoprd06.lss.emc.com [10.254.222.130]) by hop04-l1d11-si01.isus.emc.com (RSA Interceptor) for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 13:42:52 -0500
Received: from mxhub02.corp.emc.com (mxhub02.corp.emc.com [10.254.141.104])
	by mailhub.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id qBRIgqc8008213
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 13:42:52 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have installed kernel 3.7 on my Linux box, see the following uname -a output,

uname -a
Linux c210-m2-sib-3 3.7.0-030700-generic #201212102335 SMP Tue Dec 11 04:36:24 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux

Does that mean I've got VXLAN module loaded or I still need to go through some extra steps to enable or configure it? Do you have any VXLAN setup or configuration document by chance?

Thanks.

Dennis Qin

P.S. If this is not the right place to ask this kind of questions, please let me know which mailing list I should use.

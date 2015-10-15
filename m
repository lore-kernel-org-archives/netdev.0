From: "Liu, Mengke" <mengke.liu@intel.com>
Subject: [Question]: iproute2 extension for supporting lightweight tunnel
Date: Thu, 15 Oct 2015 06:26:30 +0000
Message-ID: <7DDE0CBD3BECA4418AF34146552BC32B08C3E1B9@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11164 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754989AbbJOG0c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 02:26:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to use the "lightweight tunnels" after building the Linux k=
ernel from source with "Lightweight & flow based encapsulation" support=
=2E Can you tell me how to get iproute2 extension for supporting the fo=
llowing =A0command in commit log(commit ID e69724f32e62502a6e686eae36b7=
aadfeea60dca)
       "ip route add 40.1.1.1/32 encap vxlan id 10 dst 50.1.1.2 dev vxl=
an0"=20
Thanks.

Best Regards
Mengke

From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: RE: Receive Ip packets to user space which have to be protected by IPsec
Date: Tue, 17 Jan 2012 19:33:01 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA02699512@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <ipsec-tools-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:53825 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab2AQODF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 09:03:05 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All=20
Are there method to get IP packet With tunneled ip address( basically s=
ubscriber Ip)=20
which have to be protected with Ipsec , where there is no
route added to the tunneled IP address , but the outer=20
Ip address have =A0routes added.

If there is no route added the packet will be dropped at the routing=20
=A0phase itself and may not reach the Interface, so that it can be capt=
ured=20
=A0using pf_packet.

Any guidance will be appreciated.

Thanks and Regards
Naveen

From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: linux kernel networking code review request
Date: Fri, 19 Oct 2007 16:10:04 -0700
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDB5F@XCH-NW-7V2.nw.nos.boeing.com>
References: <1192829803.22064.556.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:64229 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764943AbXJSX40 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 19:56:26 -0400
Received: from blv-av-01.boeing.com (blv-av-01.boeing.com [192.42.227.216])
	by blv-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id l9JNAYOb018662
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 16:10:44 -0700 (PDT)
Received: from blv-av-01.boeing.com (localhost [127.0.0.1])
	by blv-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id l9JNAYJu014465
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 16:10:34 -0700 (PDT)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by blv-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id l9JNAXDd014420
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 16:10:34 -0700 (PDT)
Content-class: urn:content-classes:message
In-Reply-To: <1192829803.22064.556.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I would like to get a review on some new Linux
kernel networking code. The code is based on the
2.6.23 source tree and touches three files - two
in ./net/ipv6 and one in ./include/net. What is
the proper procedure for requesting a review?

Thanks - Fred
fred.l.templin@boeing.com

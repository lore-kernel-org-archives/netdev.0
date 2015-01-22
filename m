From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Thu, 22 Jan 2015 13:48:29 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F918903CD5@HASMSX110.ger.corp.intel.com>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50097 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbbAVNse convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 08:48:34 -0500
In-Reply-To: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+config NET_CLS_OPENFLOW
+	tristate "OpenFlow classifier"
+	select NET_CLS
+	---help---
+	  If you say Y here, you will be able to classify packets based on
+	  a configurable combination of packet keys and masks accordint to
+	  OpenFlow standard.
+

Should be: according to

Regards,
Rami Rosen

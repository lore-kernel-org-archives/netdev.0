From: "Bishop, Mark" <Mark.Bishop@cooperindustries.com>
Subject: PHY config change
Date: Mon, 23 Jan 2012 20:54:06 -0500
Message-ID: <5D308BD40154E4439D82454FE483A50205C330BD@EVS4.nam.ci.root>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooperlighting-sw.cooperlighting.com ([216.130.131.68]:23763
	"EHLO cooperlighting-sw.cooperlighting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755389Ab2AXCE0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 21:04:26 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Where is a good place to change my PHY config from 100BT half duplex,
auto negotiate, to full duplex 100BT, no negotiate?

Right before the probe in the controller driver, or after a reset of the
PHY?

I am using the 'General PHY' attached to the SMSC9215 controller.  Is
there a  

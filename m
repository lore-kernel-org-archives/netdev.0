From: "Chris Friesen" <cfriesen@nortel.com>
Subject: relationship between ingress policer and netfilter hooks?
Date: Tue, 02 Jun 2009 09:30:07 -0600
Message-ID: <4A25457F.2070000@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:59153 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757221AbZFBPaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 11:30:15 -0400
Received: from zcarhxs1.corp.nortel.com (casmtp.ca.nortel.com [47.129.230.89])
	by zrtps0kp.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id n52FUFM10507
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2009 15:30:15 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

Can someone tell me where the hook is for incoming packets to be sent
through the ingress policer?

In particular, I'm trying to find out how the ingress traffic shaping
hook relates to the various netfilter hooks so that I can set them up to
behave nicely together.

Thanks,

Chris

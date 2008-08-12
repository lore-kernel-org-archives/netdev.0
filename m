From: "Pravin Bathija" <pbathija@amcc.com>
Subject: RE: [Qdisc] Prioritizing traffic per vlan using qdisc.
Date: Mon, 11 Aug 2008 17:56:58 -0700
Message-ID: <9D1E2BDCB5C57B46B56E6D80843439EB0598FBD2@SDCEXCHANGE01.ad.amcc.com>
References: <9D1E2BDCB5C57B46B56E6D80843439EB0598FBC9@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sdcmail02-ext1.amcc.com ([198.137.200.73]:50343 "EHLO
	sdcmail02.amcc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbYHLA4o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:56:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <9D1E2BDCB5C57B46B56E6D80843439EB0598FBC9@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For example if I create 3 vlans on interface 0 :  eth0.1, eth0.2 and
eth0.3 I want to assign them priorities of 1, 2 and 3 respectively (1
being the highest and 3 the lowest)

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Pravin Bathija
Sent: Monday, August 11, 2008 5:48 PM
To: netdev@vger.kernel.org
Subject: [Qdisc] Prioritizing traffic per vlan using qdisc.

Using Linux 2.6.23 I want to create multiple Vlans for voice, data,
video etc. The requirement is to prioritize each vlan on the ingress and
egress. I am looking at qdisc to do this however without success. Could
you please advise is there is a way to do this using qdisc tc(traffic
control) commands. If not - is there another way to do this in Linux ?
Any help would be greatly appreciated.

Thanks,
Pravin

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html

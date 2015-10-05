From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 09:54:38 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F91944E43E@HASMSX110.ger.corp.intel.com>
References: <20150930135141.GF2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21376 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbbJEJyk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 05:54:40 -0400
In-Reply-To: <20150930135141.GF2098@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jiri,

>In our case, we put message into skb and  ...

Just to be sure we are on the same page:

By "In our case" - I assume you are referring to the mlxsw Ethernet switch driver, right ? 

>we put message into skb and push that out as an ordinary packet. >HW then > sends us reply in a packet, similar to other rx-ed packets.

Are you referring here to messages of the EMAD protocol ?

Rami Rosen
Intel Corporation

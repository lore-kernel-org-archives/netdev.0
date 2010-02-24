From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next-2.6 PATCH v3 4/5] rtnetlink: Add VF config code to
 rtnetlink
Date: Wed, 24 Feb 2010 11:13:32 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE42DE401@rrsmsx501.amr.corp.intel.com>
References: <20100210114303.14483.71368.stgit@localhost.localdomain>
 <20100210114403.14483.11004.stgit@localhost.localdomain>
 <4B72A061.40905@trash.net>
 <EA929A9653AAE14F841771FB1DE5A1365FE3CBE343@rrsmsx501.amr.corp.intel.com>
 <4B853468.10509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52785 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757382Ab0BXSNd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 13:13:33 -0500
In-Reply-To: <4B853468.10509@trash.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Patrick McHardy [mailto:kaber@trash.net]

[snip]

>
>I just noticed the patch went in without any of these changes.
>Are you going to fix this up?

I've got a patch in Jeff's queue that takes care of the low-hanging
fruit - return codes and excessive locking. You should see this go
up pretty quickly.
 
I'm planning to look into the data structure changes today. 

-Mitch

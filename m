From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next-2.6 PATCH 2/5] if_link: Add SR-IOV configuration
	methods
Date: Tue, 2 Feb 2010 07:16:42 +0200
Message-ID: <15ddcffd1002012116la5ae23ct7754e4e9287a1a1f@mail.gmail.com>
References: <20100130103842.26633.73429.stgit@localhost.localdomain>
	 <20100130103947.26633.78452.stgit@localhost.localdomain>
	 <15ddcffd1001310625k3a1c1010w57e7cf62986c56ef@mail.gmail.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FDD55C136@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:49006 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab0BBFQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 00:16:44 -0500
Received: by bwz23 with SMTP id 23so267892bwz.21
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2010 21:16:42 -0800 (PST)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FDD55C136@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Mitch A <mitch.a.williams@intel.com> wrote:

> To be honest, Or, this completely slipped my mind. I'll add it to my to-do list.
> If it's OK with you, I'd prefer to get this set of patches in as-is and
> add the egress qos stuff later. A lot of people have been asking for
> these patches, so I'd rather not delay for this feature.

Mitch, looking on the patch series I see that except for two patches
([PATCH 1/5] pci: Add SR-IOV convenience functions and macros and
[PATCH 2/4] libnetlink: Modify parser to track the first duplicated
attributes) seven other patches have to be changed/enhanced to
incorporate the egress qos mapping. If you prefer to do that later
rather then now I am fine with that, but lets not leave that a side.

Or.

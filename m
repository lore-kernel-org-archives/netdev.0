From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 0/3] ctnetlink: allocation improvements
Date: Wed, 25 Mar 2009 21:34:04 +0100
Message-ID: <20090325203404.581023828@jonathan.eitzenberger.org>
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

this is a resend of the last three patches send last week, which are
now rebased against commit af9d32ad6718b9a of nf-net-next-2.6.

I have changed the first patch of this series to use RCU, which you
complained about after my initial post.  Other than that this series
is unchanged.

I'll send another patch shortly which adresses the points Pablo made
last week.

Many thanks!

 /holger


From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for July 20 (qlcnic)
Date: Wed, 20 Jul 2011 09:19:45 -0700
Message-ID: <20110720091945.39f0a8a5.rdunlap@xenotime.net>
References: <20110720180041.5774ca335e6697c17374dca5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-driver@qlogic.com
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110720180041.5774ca335e6697c17374dca5@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Jul 2011 18:00:41 +1000 Stephen Rothwell wrote:

> Hi all,

When CONFIG_VLAN_8021Q is not enabled:

drivers/net/qlcnic/qlcnic_main.c:4207: error: 'struct net_device' has no member named 'vlgrp'

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

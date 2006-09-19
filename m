From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 12:44:42 -0700
Message-ID: <20060919124442.0b1127c0@localhost.localdomain>
References: <20060918211759.GB31746@tentacle.sectorb.msk.ru>
	<20060918220038.GB14322@ms2.inr.ac.ru>
	<Pine.LNX.4.63.0609181452470.14338@qynat.qvtvafvgr.pbz>
	<20060919.124034.78165098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlang@digitalinsight.com, kuznet@ms2.inr.ac.ru,
	master@sectorb.msk.ru, ak@suse.de, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752008AbWISTqi@vger.kernel.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060919.124034.78165098.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sky2 hardware (and others) can timestamp in hardware, but trying
to keep device ticks and system clock in sync looked too nasty
to contemplate actually using it.

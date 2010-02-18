From: lkml@Think-Future.de
Subject: Re: PROBLEM: oops w/ bridge in 2.6.32.7
Date: Thu, 18 Feb 2010 14:34:46 +0100
Message-ID: <20100218133446.GF2165@localhost>
References: <20100208154735.1d60f43c@nehalam>
Reply-To: lkml@Think-Future.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel-Liste <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100208154735.1d60f43c@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Hi,

  Reported to virtualbox bugtracker.

  The crash so far only happens when starting virtualbox. W/o bridging is working.
  Plain and within a box.

  Thank you.

  Nils

PS: We once had quite unstable kernels using bridge and ebtables modules.
  When loaded those kernel crashed quite fast. This was _some_ versions ago.
  maybe mid-summer 2009? Anyhow, nothing to dig in now except you have a hunch. 
  ;) Just felt to let you know while talking about bridging...

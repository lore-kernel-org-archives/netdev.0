From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: ixgbe: Unsupported SFP+ modules on 10Gbit/s X520-DA2 NIC?
Date: Wed, 18 Jan 2012 09:13:51 -0800
Message-ID: <20120118091351.000052fc@unknown>
References: <1326886258.19261.25.camel@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48675 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932214Ab2ARRNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 12:13:52 -0500
In-Reply-To: <1326886258.19261.25.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jan 2012 03:30:58 -0800
Jesper Dangaard Brouer <hawk@comx.dk> wrote:
> I just bought three 10Gbit/s X520-DA2 NICs (82599 based) for
> production usage, but I cannot get them to accept any of my 10Gbit/s
> SFP+ modules (4 different tried). According to the documentation I can
> find, the X520-DA2 NIC should support fiber optics SFP+ modules.
Hi Jesper, 

For X520 adapters, the documentation[1] states that which SFP+
adapters are/are not supported.  Direct attach cables are also
supported.

[1] http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm

> The SFP+ modules does work in another 82599 based NIC in the same
> machine (engineering sample from PJ).

Sorry, can't help you with that one, those samples are different
hardware.
 
Jesse

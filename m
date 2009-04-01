From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10GbEPCIe adapter
Date: Tue, 31 Mar 2009 23:36:11 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF03C@nekter>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter> <49D257D0.9050104@intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter> <20090401025327.GA11687@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Yu Zhao" <yu.zhao@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:16164 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254AbZDADgO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 23:36:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090401025327.GA11687@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, and that's what the PCI subsystem does. If the vxge VF is
identical
> to its PF, then vxge should be able to drive both PF and VF without
any
> modification.
[Ram] Ok. In that case, is the call to pci_enable/disable_sriov still
required for vxge?

Ram

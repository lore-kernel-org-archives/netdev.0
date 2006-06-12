From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Mon, 12 Jun 2006 16:55:01 -0400
Message-ID: <20060612205501.GB24632@redhat.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity> <20060612152434.GA14851@tuxdriver.com> <20060612153958.GA6719@divinity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, proski@gnu.org,
	hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37019 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751146AbWFLUzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 16:55:41 -0400
To: Faidon Liambotis <faidon@cube.gr>
Content-Disposition: inline
In-Reply-To: <20060612153958.GA6719@divinity>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 06:39:58PM +0300, Faidon Liambotis wrote:
 
 > FWIW, I think we've experienced a similar situation like this in the
 > past in the networking land and the consensus was to completely remove
 > the other driver. I'm referring to e100/eepro100, of course.

The difference with e100/eepro100, was that there the interface
name remained constant regardless of which driver you were using,
which isn't the case with orinoco->hostap.

		Dave

-- 
http://www.codemonkey.org.uk

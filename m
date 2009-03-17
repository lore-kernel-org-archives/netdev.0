From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Intel 82567LM e1000e DHCP problem/question
Date: Tue, 17 Mar 2009 10:27:41 +0100
Message-ID: <87mybk1otu.fsf@nemi.mork.no>
References: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl>
	<alpine.WNT.2.00.0903161133100.5116@jbrandeb-desk1.amr.corp.intel.com>
	<BAY143-W2353DFECB11A239842C4C3B99B0@phx.gbl>
	<alpine.WNT.1.10.0903162202080.5440@jbrandeb-MOBL1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg\, Jesse" <jesse.brandeburg@intel.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel\@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Pelle Svensson <pelle2004@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57363 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696AbZCQKga convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:36:30 -0400
In-Reply-To: <alpine.WNT.1.10.0903162202080.5440@jbrandeb-MOBL1.amr.corp.intel.com>
	(Jesse Brandeburg's message of "Mon, 16 Mar 2009 22:23:09 -0700
	(Pacific Daylight Time)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Brandeburg, Jesse" <jesse.brandeburg@intel.com> writes:
> On Mon, 16 Mar 2009, Pelle Svensson wrote:
>
>> I tried to hit Ctrl-P frequently during the boot process but it newe=
r display any
>> management setup. I'm running Fedora 10 on Lenovo T500 bios 1.20 (6F=
ET50WW).
>
> Okay, maybe there is a bios setting you can change.
>
> I am not experienced in configuring this on a t500, so I can't give y=
ou=20
> direct instructions.

Assuming it's similar to a Thinkpad X301:

 ThinkVantage -> F1 -> Config -> Intel(R) AMT -> Disable

Totally offtopic, but IBM used to have a nice support tool called BIOS
simulators: http://www-307.ibm.com/pc/support/site.wss/TPAD-SIMS.html
But I haven't been able to find such simulators for the newer Lenovo
Thinkpads.




Bj=C3=B8rn

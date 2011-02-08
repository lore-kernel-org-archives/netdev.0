From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: Oops in tcp_output.c, kernel 2.6.38-rc3
Date: Tue, 8 Feb 2011 14:46:01 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90017BADD17C@orsmsx509.amr.corp.intel.com>
References: <20110204153254.5c37c6f2@katamari>
 <20110207.130234.112590109.davem@davemloft.net>
 <alpine.WNT.2.00.1102081401480.5424@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "cebbert@redhat.com" <cebbert@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60523 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab1BHWqD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 17:46:03 -0500
In-Reply-To: <alpine.WNT.2.00.1102081401480.5424@JBRANDEB-DESK2.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Brandeburg, Jesse
>Sent: Tuesday, February 08, 2011 2:07 PM
>To: David Miller
>Cc: cebbert@redhat.com; netdev@vger.kernel.org; ilpo.jarvinen@helsinki.fi;
>Allan, Bruce W
>Subject: Re: Oops in tcp_output.c, kernel 2.6.38-rc3
>
>glaring at the bug dump shows e1000e as the only network driver that i can
>see, hardware seems to be the ICH10 chipset.  Copied bruce in case he's
>seen or heard anything.
>
>appears to be this system:
>http://www.asus.com/Product.aspx?P_ID=qH6ZSEJ8EPY6HoNU&content=specifications

Sorry, no, this is new to me.  BTW, it's the ICH10R chipset which is
different from other ICH10* chipsets, just FYI.

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 14:34:43 -0700
Message-ID: <46F438F3.5030201@intel.com>
References: <1190359905.3551.28.camel@magi.nadr>	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>	 <46F3E695.7010604@candelatech.com> <1190409160.4231.29.camel@localhost>	 <46F435CD.1090502@intel.com> <1190410187.4231.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Emil Micek <emil.micek@tkrjasek.cz>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5972 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755461AbXIUVer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 17:34:47 -0400
In-Reply-To: <1190410187.4231.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
>> AFAIK the RX side is fully covered 
> 
> so you can handle both 64B and 68B?

I never saw any bugreports about e1000 not being able to accept vlan packets
because of this, so I'm quite certain it works OK, feel free to find me a case
where this isn't so :)

Auke

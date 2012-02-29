From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Wed, 29 Feb 2012 08:57:26 -0500
Message-ID: <1330523846.18226.18.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu>  <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu>  <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com>
	 <4F4DB440.50509@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, kernel@wantstofly.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F4DB440.50509@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-02-28 at 21:14 -0800, John Fastabend wrote:

> Just checked looks like the DSA infrastructure has commands to enable
> STP so guess it is doing learning.

IIRC, Lennert built some of this stuff tied to the kernel.

cheers,
jamal

